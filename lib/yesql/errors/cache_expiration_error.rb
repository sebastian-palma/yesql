# frozen_string_literal: true

module YeSQL
  module Errors
    module CacheExpirationError
      def validate_cache_expiration(expires_in)
        raise ArgumentError, MESSAGE unless expires_in.is_a?(ActiveSupport::Duration)
      end

      MESSAGE = <<~MSG
        Missing mandatory `expires_in` option for `cache`.

        Can not cache the result of the query without an expiration date.
      MSG
      private_constant :MESSAGE
    end
  end
end
