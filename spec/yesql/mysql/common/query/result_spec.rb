# frozen_string_literal: true

require 'spec_helper'
require 'yesql/statement'
require 'yesql/query/result'
require 'mysql2'

require "#{RSPEC_ROOT}/minimalmysql/config/environment"
require "#{RSPEC_ROOT}/yesql/shared/query/result"

describe ::YeSQL::Query::Result do
  describe '.call' do
    include_context 'with ::YeSQL::Query::Result'

    it_behaves_like 'an exec_query execution', :mysql
    it_behaves_like 'a view exec_query execution', :mysql

    context 'with Rails 5', :mysql, :rails5 do
      let(:raw_connection) { instance_double('ActiveRecord::Base.connection.raw_connection') }
      let(:prepare) { instance_double('ActiveRecord::Base.connection.raw_connection.prepare') }
      let(:execute) { double }

      before do
        allow(connection).to receive(:adapter_name).and_return('Mysql2')
        allow(connection).to receive(:raw_connection).and_return(raw_connection)
        allow(raw_connection).to receive(:prepare).and_return(prepare)
        allow(prepare).to receive(:execute)
      end

      it '"manually" executes the statement passing the binds' do
        result
        expect(prepare).to have_received(:execute).with(*binds)
      end
    end
  end
end
