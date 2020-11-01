# frozen_string_literal: true

require 'spec_helper'

shared_context 'with ::YeSQL::Statement' do
  let(:file_path) { 'sites' }
  let(:bindings) { { site: 'OF', sites: %w[AC AF AB] } }
  let(:binds) { ::YeSQL::Bindings::Extractor.new(bindings: bindings).call }
end

shared_context 'when binding a statement' do
  subject(:bound) { described_class.new(bindings, file_path).bound }

  before { create_sql_file(file_path, sql) }

  after { remove_generated_files }

  shared_examples 'a regular bound statement' do |expectation|
    let(:sql) { "SELECT :keyword, CONCAT(:keyword, ' Shakala!');" }
    let(:bindings) { { keyword: 'BOOM' } }

    it 'replaces a single named bind with two positional binds' do
      expect(bound).to eq(expectation)
    end
  end

  shared_examples 'an unquoted bound statement' do
    let(:interval) { 7 }
    let(:bindings) { { interval: interval } }
    let(:sql) { 'CREATE VIEW tmp AS SELECT NOW() + INTERVAL :interval DAYS;' }

    it 'replaces the named bindings by their values' do
      expect(bound).to eq("CREATE VIEW tmp AS SELECT NOW() + INTERVAL #{interval} DAYS;")
    end
  end

  shared_examples 'a quoted bound statement' do
    let(:name) { 'papo' }
    let(:bindings) { { name: name } }
    let(:sql) { 'CREATE VIEW tmp AS SELECT * FROM t WHERE name = :name;' }

    before do
      ::ActiveRecord::Base.connection.execute('CREATE TEMPORARY TABLE t(id INT, name VARCHAR(15));')
      ::ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO t(id, name) VALUES (1, 'sandy'), (2, 'papo');
      SQL
    end

    it 'replaces the named bindings by their values' do
      expect(bound).to eq("CREATE VIEW tmp AS SELECT * FROM t WHERE name = '#{name}';")
    end
  end
end

shared_context 'when processing a view statement' do
  shared_examples 'a view' do |view_stmt|
    let(:sql) do
      break view_stmt if view_stmt.end_with?(';')

      "#{view_stmt} SELECT * FROM t WHERE name = :name;"
    end

    it { expect(view).to be_a_view }
  end

  shared_examples 'not a view' do |stmt|
    let(:sql) { stmt }

    it { expect(view).not_to be_a_view }
  end

  subject(:view) { described_class.new({ name: 'name' }, file_path) }

  before { create_sql_file(file_path, sql) }

  after { remove_generated_files }
end

shared_context 'when converting to string' do
  subject(:to_s) { described_class.new(bindings, file_path).to_s }

  before { create_sql_file(file_path, 'SELECT *, :site FROM tmp WHERE LOWER(site) IN (:sites);') }

  after { remove_generated_files }

  it { expect(to_s).to eq(::YeSQL::Utils::Read.statement(file_path, readable: true)) }
end
