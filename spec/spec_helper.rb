# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'yesql'
require 'open3'
require 'pry'

require 'support/access'
require 'support/cleaning'
require 'support/commands'
require 'support/query_files'

RSpec.configure do |config|
  config.include ::YeSQL::Access
  config.include ::YeSQL::Cleaning
  config.include ::YeSQL::Commands
  config.include ::YeSQL::QueryFiles

  config.order = :random

  config.around(:each, pg: true) do |example|
    on_minimal(:pg) do
      example.run
    end
  end

  config.around(:each, mysql: true) do |example|
    on_minimal(:mysql) do
      example.run
    end
  end
end
