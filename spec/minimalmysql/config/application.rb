# frozen_string_literal: true

require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"

Bundler.require(*Rails.groups)

module Minimalmysql
  class Application < Rails::Application
    config.load_defaults 6.0
    config.api_only = true
  end
end
