# frozen_string_literal: true

require 'spec_helper'

shared_context 'with ::YeSQL::Query::Result' do
  subject(:result) do
    described_class.new(binds: binds,
                        bind_statement: statement,
                        file_path: file_path,
                        prepare: prepare_option).call
  end

  let(:bindings)       { { temp: 'jej', sites: %w[foo NO NA] } }
  let(:binds)          { ::YeSQL::Bindings::Extractor.new(bindings: bindings).call }
  let(:bound)          { statement.bound }
  let(:connection)     { instance_double('ActiveRecord::Base.connection') }
  let(:file_path)      { 'imaginary_path/imaginary_file' }
  let(:prepare_option) { true }
  let(:sql)            { 'SELECT id, :temp FROM foo WHERE LOWER(site) IN (:sites);' }
  let(:statement)      { ::YeSQL::Statement.new(bindings, file_path) }

  before do
    create_sql_file(file_path, sql)
    allow(connection).to receive(:exec_query)
    allow(connection).to receive(:adapter_name)
    allow(::ActiveRecord::Base).to receive(:connection).and_return(connection)
  end

  after { remove_generated_files }
end

shared_examples 'a view exec_query execution' do |adapter, rails_version|
  let(:sql) { 'CREATE VIEW tmp AS SELECT * FROM t;' }

  it 'executes the query with the given binds', adapter, rails_version do
    result
    expect(connection).to have_received(:exec_query).with(bound).once
  end
end

shared_examples 'an exec_query execution' do |adapter, rails_version|
  it 'executes the query with the given binds', adapter, rails_version do
    result
    expect(connection).to have_received(:exec_query).with(bound, file_path, binds,
                                                          prepare: prepare_option).once
  end
end
