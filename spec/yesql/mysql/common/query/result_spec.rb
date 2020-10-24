# frozen_string_literal: true

require 'spec_helper'
require 'yesql/query/result'
require 'mysql2'
require_relative '../../../../minimalmysql/config/environment'

describe ::YeSQL::Query::Result do
  describe '.call' do
    subject do
      described_class.new(
        binds: binds,
        bind_statement: bind_statement,
        file_path: file_path,
        prepare: prepare_option
      )
    end

    let(:file_path) { 'imaginary_path/imaginary_file' }
    let(:prepare_option) { true }
    let(:bind_statement) { 'SELECT id, ? FROM foo WHERE LOWER(site) IN (?, ?);' }
    let(:connection) { ActiveRecord::Base.connection }
    let(:raw_connection) { connection.raw_connection }
    let(:prepare) { Mysql2::Statement.new }
    let(:binds) { %w[foo NO NA] }
    let(:result) { subject.call }

    before do
      ActiveRecord::Base.connection.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS foo (id INT, site VARCHAR(50));
      SQL
    end

    after(:all) do
      ActiveRecord::Base.connection.execute('DROP TABLE foo;')
    end

    context 'with Rails 5', :rails5 do
      it do
        expect(connection).to receive(:raw_connection).and_return(raw_connection)
        expect(raw_connection).to receive(:prepare).with(bind_statement).and_return(prepare)
        expect(prepare).to receive(:execute).with(*binds)
        result
      end
    end

    context 'with Rails != 5' do
      it do
        expect(connection).to(
          receive(:exec_query).with(
            bind_statement, file_path, binds, prepare: prepare_option
          )
        )
        result
      end
    end
  end
end
