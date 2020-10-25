# frozen_string_literal: true

require 'yesql'
require 'forwardable'
require 'yesql/common/adapter'

module ::YeSQL
  module Query
    class Result
      extend Forwardable

      include ::YeSQL::Common::Adapter

      def initialize(binds:, bind_statement:, file_path:, prepare:)
        @binds = binds
        @bind_statement = bind_statement
        @file_path = file_path
        @prepare_option = prepare
      end

      def call
        return rails5_result if ::Rails::VERSION::MAJOR == 5 && mysql?

        exec_query(bind_statement, file_path, binds, prepare: prepare_option)
      end

      private

      attr_reader :binds, :bind_statement, :file_path, :prepare_option

      def_delegators(:connection, :exec_query, :raw_connection)
      def_delegators(:raw_connection, :prepare)

      def connection
        ActiveRecord::Base.connection
      end

      def rails5_result
        prepare(bind_statement).execute(*binds)
      end
    end
  end
end
