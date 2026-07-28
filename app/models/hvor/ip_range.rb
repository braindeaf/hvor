module Hvor
  class IPRange < ApplicationRecord
    enum :ip_version, { ipv4: 0, ipv6: 1 }

    def self.lookup_country_code(ip)
      find_containing(ip)&.country_code
    end

    def self.find_containing(ip)
      normalized = Hvor::IpNormalizer.normalize(ip)
      from_column, to_column = normalized.version == :ipv4 ? %w[ipv4_from ipv4_to] : %w[ipv6_from ipv6_to]

      range = where(ip_version: normalized.version)
        .where("#{from_column} <= ?", normalized.value)
        .order(from_column => :desc)
        .first

      range if range && range[to_column] && range[to_column] >= normalized.value
    end
  end
end
