# frozen_string_literal: true

require 'forwardable'

require 'yesql/utils/read'
require 'yesql/bindings/extractor'
require 'yesql/common/adapter'

module ::YeSQL
  class Statement
    extend Forwardable

    include ::YeSQL::Common::Adapter

    def initialize(bindings = {}, file_path)
      @bindings = bindings
      @connection = ::ActiveRecord::Base.connection
      @file_path = file_path
    end

    def bound
      to_s.gsub(::YeSQL::BIND_REGEX) do |match|
        extractor[match[/(\w+)/].to_sym].tap do |extract|
          break quote(extract[:value]) if view?

          break extract[:bind][:vars]
        end
      end
    end

    def to_s
      @to_s ||= ::YeSQL::Utils::Read.statement(file_path, readable: true)
    end

    def view?
      to_s =~ /^create\s.*view\s/i
    end

    private

    def_delegator(:connection, :quote)

    attr_reader :bindings, :connection, :file_path

    def extractor
      ::YeSQL::Bindings::Extractor.new(bindings: bindings).call
    end
  end
end
