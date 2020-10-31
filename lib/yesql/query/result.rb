# frozen_string_literal: true

require 'yesql'
require 'forwardable'
require 'yesql/common/adapter'

module ::YeSQL
  module Query
    class Result
      extend Forwardable

      include ::YeSQL::Common::Adapter

      def initialize(binds: [], bind_statement:, file_path:, prepare:)
        @binds = binds
        @bind_statement = bind_statement
        @connection = ActiveRecord::Base.connection
        @file_path = file_path
        @prepare_option = prepare
      end

      def call
        return view_result   if view?
        return rails5_result if ::Rails::VERSION::MAJOR == 5 && mysql?

        exec_query(bound, file_path, binds, prepare: prepare_option)
      end

      private

      attr_reader :binds, :bind_statement, :connection, :file_path, :prepare_option

      def_delegators(:bind_statement, :bound, :to_s, :view?)
      def_delegators(:connection,     :exec_query, :raw_connection)
      def_delegators(:raw_connection, :prepare)

      def view_result
        exec_query(bound)
      end

      def rails5_result
        prepare(bound).execute(*binds)
      end
    end
  end
end
