# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'yesql'
require 'open3'
require 'dry/configurable/test_interface'

require File.expand_path("#{File.dirname(__FILE__)}/minimalpg/config/environment", __dir__)

require 'support/access'
require 'support/cleaning'
require 'support/commands'
require 'support/query_files'

RSpec.configure do |config|
  config.include YeSQL::Access
  config.include YeSQL::Cleaning
  config.include YeSQL::Commands
  config.include YeSQL::QueryFiles

  config.around(:each, minimalpg: true) do |example|
    on_minimal(:pg) { example.run }
  end
end

module YeSQL
  enable_test_interface
end
