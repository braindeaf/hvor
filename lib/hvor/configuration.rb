module Hvor
  class Configuration
    attr_accessor :api_token, :ipv4_product_code, :ipv6_product_code,
                  :cache_store, :cache_expires_in, :import_batch_size,
                  :download_timeout, :queue_name

    def initialize
      @api_token = nil
      @ipv4_product_code = "DB1LITECSV"
      @ipv6_product_code = "DB1LITECSVIPV6"
      @cache_store = -> { Rails.cache }
      @cache_expires_in = 24.hours
      @import_batch_size = 5_000
      @download_timeout = 60
      @queue_name = :hvor
    end

    def cache
      cache_store.call
    end
  end
end
