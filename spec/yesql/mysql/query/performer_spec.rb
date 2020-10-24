# frozen_string_literal: true

require 'spec_helper'
require 'yesql/query/performer'
require 'yesql/bindings/binder'
require_relative '../../../minimalmysql/config/environment'

describe ::YeSQL::Query::Performer, :mysql do
  describe '.call' do
    before(:all) do
      on_minimal(:mysql) do
        run_command('rails g model article_stat logdate:date pageviews:integer site --force')
        run_command('rake db:migrate')

        create_article_stats_by_site

        require './app/models/article_stat'
      end
    end

    before do
      ActiveRecord::Base.connection.begin_transaction(joinable: false)
    end

    after do
      ActiveRecord::Base.connection.rollback_transaction
    end

    after(:all) do
      on_minimal(:mysql) { undo_model_changes }
    end

    let(:bindings) { { from_date: '2020-02-01', current_site: 'af', site: 'cl' } }
    let(:bind_statement) { ::YeSQL::Bindings::Binder.bind_statement(file_path, bindings) }
    let(:article_stat) do
      ArticleStat.create(site: bindings[:site], logdate: bindings[:from_date], pageviews: 123)
    end

    subject do
      described_class.new(bind_statement: bind_statement, file_path: file_path, bindings: bindings)
    end

    describe 'binds' do
      context 'when a positional bind is used more than once' do
        let(:file_path) { 'article_stats/in_site' }
        let(:site) { 'af' }
        let(:bindings) { { site: site } }

        before { create_sql_file(file_path, 'SELECT :site, :site') }

        it 'executes the query with repeated binds' do
          expect(subject.call).to eq([[site, site]])
        end
      end

      context 'with dozens of binds' do
        let(:created_at) { '2020-01-01' }
        let(:file_path) { 'article_stats/by_id' }
        let(:site) { 'af' }
        let(:bindings) do
          { site: site, ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], created_at: created_at }
        end

        before do
          create_sql_file(file_path, <<~SQL)
            SELECT id, :site
            FROM article_stats
            WHERE id IN (:ids)
            OR created_at > CAST(:created_at AS DATE)
          SQL

          article_stat
        end

        it 'orders them by their integer value - otherwise it mixes binds which breaks when casting' do
          expect(subject.call).to eq([[article_stat.id, site]])
        end
      end
    end

    describe 'SELECT' do
      describe 'IN' do
        let(:file_path) { 'article_stats/in_site' }
        let(:bindings) { { sites: %w[cl mx], ids: [article_stat_1.id, article_stat_2.id] } }
        let(:result) { subject.call }
        let!(:article_stat_1) { ArticleStat.create(site: 'cl', pageviews: 1) }
        let!(:article_stat_2) { ArticleStat.create(site: 'MX', pageviews: 100) }
        let!(:article_stat_3) { ArticleStat.create(site: 'ua', pageviews: 100) }

        before do
          create_sql_file(file_path, <<~SQL)
            SELECT id
            FROM article_stats
            WHERE LOWER(site) IN (:sites)
            AND id IN (:ids)
            ORDER BY id;
          SQL
        end

        it 'returns the records matching the IN clause' do
          expect(result).to eq([[article_stat_1.id], [article_stat_2.id]])
        end
      end

      describe '`cache` option' do
        let(:file_path) { 'article_stats/by_site' }
        let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

        before do
          allow(Rails).to receive(:cache).and_return(memory_store)
          Rails.cache.clear
        end

        context 'when `{}`' do
          before { subject.call }

          it 'does not cache the return value' do
            expect(Rails.cache.fetch(file_path)).to be_nil
          end
        end

        context 'when not `{}`' do
          let(:result) { [['af', article_stat.id, article_stat.pageviews, article_stat.site]] }
          let(:cache) { { expires_in: 1.hour } }

          before { article_stat }

          context 'with a `key` value' do
            let(:cache_key) { 'temp' }

            before do
              described_class.new(
                bind_statement: bind_statement,
                bindings: bindings,
                cache: cache.merge(key: cache_key),
                file_path: file_path
              ).call
            end

            it 'caches the return value with the given cache key' do
              expect(Rails.cache.fetch(cache_key)).to eq(result)
            end
          end

          context 'without a `key` value' do
            before do
              described_class.new(
                bind_statement: bind_statement,
                bindings: bindings,
                cache: cache,
                file_path: file_path
              ).call
            end

            it 'caches the return value using the file_path argument as the key' do
              expect(Rails.cache.fetch(file_path)).to eq(result)
            end

            it 'caches the return value with the given expiration time' do
              expect(
                Rails.cache.send(:read_entry, file_path).instance_variable_get(:@expires_in)
              ).to eq(cache[:expires_in])
            end
          end
        end
      end

      describe '`prepare` option' do
        let(:file_path) { 'article_stats/by_site' }

        context 'when `false` - or nothing given' do
          it 'does not create a prepared statement' do
            expect {
              described_class.new(
                bind_statement: bind_statement,
                file_path: file_path,
                bindings: bindings
              ).call
            }.not_to change {
              ActiveRecord::Base.connection.exec_query(<<~SQL).first['count']
                SELECT COUNT(*) AS count FROM performance_schema.prepared_statements_instances
              SQL
            }
          end
        end

        context 'when `true`' do
          it 'creates a prepared statement with the content of `file_path`' do
            expect {
              described_class.new(
                bind_statement: bind_statement,
                file_path: file_path,
                bindings: bindings,
                prepare: true
              ).call
            }.to change {
              ActiveRecord::Base.connection.exec_query(<<~SQL).first['count']
                SELECT COUNT(*) AS count FROM performance_schema.prepared_statements_instances
              SQL
            }.from(0).to(1)
          end
        end
      end

      describe '`output` option' do
        let(:file_path) { 'article_stats/by_site' }

        before { article_stat }

        context 'with "rows" `output`' do
          it 'returns an array of arrays with every fetched row value' do
            expect(
              described_class.new(
                bind_statement: bind_statement, file_path: file_path, bindings: bindings
              ).call
            ).to eq([['af', article_stat.id, article_stat.pageviews, article_stat.site]])
          end
        end

        context 'with "columns" `output`' do
          it 'returns an array containing the names (string) of the columns retrieved from the statement' do
            expect(
              described_class.new(
                bind_statement: bind_statement,
                bindings: bindings,
                file_path: file_path,
                output: :columns
              ).call
            ).to eq(%w[current_site id pageviews site])
          end
        end

        context 'with "hash" `output`' do
          it 'returns an array of hashes where every key is a column and the value is the corresponding row value' do
            expect(
              described_class.new(
                bind_statement: bind_statement,
                bindings: bindings,
                file_path: file_path,
                output: :hash
              ).call
            ).to eq([{ current_site: 'af', id: article_stat.id, pageviews: article_stat.pageviews,
                       site: 'cl' }])
          end
        end
      end

      describe 'INSERT INTO' do
        let(:file_path) { 'article_stats/insert_returning_id_pageviews' }
        let(:id) { 666 }
        let(:pageviews) { 321 }
        let(:site) { 'ua' }
        let(:bindings) { { id: id, pageviews: pageviews, site: site } }

        before do
          create_sql_file(file_path, <<~SQL)
            INSERT INTO
              article_stats (id, logdate, pageviews, site, created_at, updated_at)
              VALUES (:id, CURRENT_DATE, :pageviews, :site, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
          SQL
        end

        it 'inserts the data and returns the columns from the RETURNING clause' do
          expect(subject.call).to eq([])
          expect(ArticleStat.pluck(:id, :pageviews, :site)).to eq([[id, pageviews, site]])
        end
      end
    end
  end
end
