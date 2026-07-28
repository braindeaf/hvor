require "hvor/version"
require "hvor/configuration"
require "hvor/engine"

module Hvor
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def lookup(ip)
      configuration.cache.fetch("hvor/lookup/#{ip}", expires_in: configuration.cache_expires_in) do
        Hvor::IPRange.lookup_country_code(ip)
      end
    end
  end
end
