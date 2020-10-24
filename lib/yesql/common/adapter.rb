# frozen_string_literal: true

require 'forwardable'

module ::YeSQL
  module Common
    module Adapter
      extend Forwardable

      # `adapter` might be a complex object, but
      # for the sake of brevity it's just a string
      def adapter
        ::ActiveRecord::Base.connection.adapter_name
      end

      def mysql?
        adapter == 'Mysql2'
      end

      def pg?
        adapter == 'PostgreSQL'
      end
    end
  end
end
