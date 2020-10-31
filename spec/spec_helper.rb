# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'yesql'
require 'open3'
require 'pry'

require 'support/access'
require 'support/cleaning'
require 'support/commands'
require 'support/query_files'

require './spec/yesql/shared/statement'

class Object
  def d
    tap { |obj| p obj }
  end
end

RSPEC_ROOT = File.dirname(__FILE__).freeze

RSpec.configure do |config|
  config.include ::YeSQL::Access
  config.include ::YeSQL::Cleaning
  config.include ::YeSQL::Commands
  config.include ::YeSQL::QueryFiles

  config.shared_context_metadata_behavior = :apply_to_host_groups

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

  config.before(:each, statement: true) do |example|
    config.include_context 'with ::YeSQL::Statement' do
      example.run
    end
  end
end
