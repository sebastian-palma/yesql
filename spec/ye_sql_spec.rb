# frozen_string_literal: true

require 'spec_helper'
require 'yesql/query/performer'

describe ::YeSQL, :minimalpg do
  before(:all) do
    on_minimal(:pg) { create_article_stats_by_site }
  end

  after(:all) do
    on_minimal(:pg) { remove_generated_files }
  end

  it 'test that it has a version_number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe 'YeSQL.config.path' do
    let(:statement) { "SELECT * FROM pg_prepared_statements;\n" }

    before do
      described_class.config.path = 'app/queries'
      create_sql_file('get_current_time', statement)
    end

    after do
      remove_path
      described_class.reset_config
    end

    it 'reads the files from the given folder' do
      expect(::YeSQL::Utils::Read.statement('get_current_time')).to eq(statement)
    end
  end

  describe '.YeSQL' do
    let(:file_path) { 'article_stats/by_site' }
    let(:bindings) { { from_date: '2020-02-01', current_site: 'af', site: 'cl' } }
    let(:cache) { { expires_in: 30.minutes } }
    let(:dummy) { Class.new { include YeSQL } }

    it 'invokes ::YeSQL::Query::Performer.new(...).call if no exceptions raised' do
      expect(::YeSQL::Query::Performer).to(
        receive(:new).with(
          bindings: bindings,
          bind_statement: ::YeSQL::Bindings::Binder.bind_statement(file_path, bindings),
          cache: cache,
          file_path: file_path,
          output: :rows,
          prepare: nil
        ).once.and_return(
          double(:scope).tap { |scope| expect(scope).to receive(:call).once }
        )
      )
      dummy.new.YeSQL(file_path, bindings, { cache: cache })
    end

    describe '`file_path` argument' do
      context 'when the given file does not exist' do
        let(:file_path) { 'nonexisting_file' }

        before { create_sql_file('another_one', "SELECT * FROM users;\n") }

        it do
          expect { dummy.new.YeSQL(file_path) }.to raise_error(NotImplementedError, <<~MSG)

            SQL file "#{file_path}" does not exist in #{described_class.config.path}.

            Available SQL files are:

            - app/yesql/article_stats/by_site.sql
            - app/yesql/another_one.sql

          MSG
        end
      end
    end

    describe '`bindings` argument' do
      context 'when SQL statement has bind parameters but YeSQL was invoked without `bindings`' do
        it do
          expect { dummy.new.YeSQL(file_path) }.to raise_error(ArgumentError, <<~MSG)

            YeSQL invoked without bindings.

            Expected bindings are:

            - `current_site`
            - `from_date`
            - `site`

          MSG
        end
      end

      context 'when SQL statement does not have bind parameters and YeSQL was invoked without `bindings`' do
        let(:file_path) { 'article_stats' }

        before { create_sql_file(file_path, "SELECT * FROM article_stats;\n") }

        it do
          expect(::YeSQL::Query::Performer).to(
            receive(:new).once.and_return(
              double(:scope).tap { |scope| expect(scope).to receive(:call).once }
            )
          )
          expect { dummy.new.YeSQL(file_path) }.to_not raise_error
        end
      end
    end

    describe '`cache` option' do
      context 'when not `{}`' do
        context 'without a `expires_in` value' do
          it do
            expect do
              dummy.new.YeSQL(file_path, bindings, cache: { key: 'orale' })
            end.to raise_error(ArgumentError, <<~MSG)
              Missing mandatory `expires_in` option for `cache`.

              Can not cache the result of the query without an expiration date.
            MSG
          end
        end
      end
    end

    describe '`output` option' do
      context 'with unsupported `output`' do
        let(:output) { :array }

        it do
          expect do
            dummy.new.YeSQL(file_path, bindings, output: output)
          end.to raise_error(ArgumentError, <<~MSG)
            Unsupported `output` option given `#{output}`. Possible values are:
              - `columns`: returns an array with the columns from the result.
              - `hash`: returns an array of hashes combining both, the columns and rows from the statement result.
              - `rows`: returns an array of arrays for each row from the given SQL statement.
          MSG
        end
      end
    end
  end
end
