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
    on_minimal(:pg) { example.run }
  end

  config.around(:each, mysql: true) do |example|
    on_minimal(:mysql) { example.run }
  end

  config.before(:each, rails5: true) do
    stub_const('::Rails::VERSION::MAJOR', 5)
  end

  config.before(:each, mysql_adapter: true) do
    allow(subject).to receive(:mysql?).and_return(true)
    allow(subject).to receive(:pg?).and_return(false)
  end

  config.before(:each, pg_adapter: true) do
    allow(subject).to receive(:mysql?).and_return(false)
    allow(subject).to receive(:pg?).and_return(true)
  end
end
