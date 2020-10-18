# frozen_string_literal: true

module ::YeSQL
  module Config
    class Configuration
      attr_accessor :path

      DEFAULT_PATH = 'app/yesql'

      def initialize
        @path = DEFAULT_PATH
      end
    end
  end

  class << self
    def config
      @config ||= ::YeSQL::Configuration.new
    end

    def configure
      yield config if block_given?
    end

    def reset_config
      tap do |conf|
        conf.configure do |configuration|
          configuration.path = ::YeSQL::Configuration::DEFAULT_PATH
        end
      end
    end
  end
end
