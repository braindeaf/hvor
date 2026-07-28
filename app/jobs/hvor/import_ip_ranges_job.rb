module Hvor
  class ImportIpRangesJob < ApplicationJob
    queue_as { Hvor.configuration.queue_name }

    LOCK_KEY = "hvor/import_ip_ranges_job/lock"

    def perform
      acquired_lock = Hvor.configuration.cache.write(LOCK_KEY, true, unless_exist: true)
      return unless acquired_lock

      ipv4_zip = Hvor::Downloader.new(Hvor.configuration.ipv4_product_code).call
      ipv6_zip = Hvor::Downloader.new(Hvor.configuration.ipv6_product_code).call

      Hvor::Importer.new.import(ipv4_zip: ipv4_zip, ipv6_zip: ipv6_zip)
    ensure
      [ ipv4_zip, ipv6_zip ].each { |file| file&.close! }
      Hvor.configuration.cache.delete(LOCK_KEY) if acquired_lock
    end
  end
end
