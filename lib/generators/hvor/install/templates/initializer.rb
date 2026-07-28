Hvor.configure do |config|
  # Token from your IP2Location LITE account: https://lite.ip2location.com/
  config.api_token = Rails.application.credentials.dig(:hvor, :ip2location_token) || ENV["IP2LOCATION_TOKEN"]

  # LITE product codes for the country-only database (DB1). See
  # https://lite.ip2location.com/database/db1-ip-country for other databases.
  # config.ipv4_product_code = "DB1LITECSV"
  # config.ipv6_product_code = "DB1LITECSVIPV6"

  # Hvor.lookup(ip) caches results here.
  # config.cache_store = -> { Rails.cache }
  # config.cache_expires_in = 24.hours

  # config.import_batch_size = 5_000
  # config.download_timeout = 60
  # config.queue_name = :hvor
end
