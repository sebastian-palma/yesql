# frozen_string_literal: true

require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module Minimalpg
  class Application < Rails::Application
    config.api_only = true
    config.eager_load = false
  end
end
