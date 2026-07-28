require "ipaddr"

module Hvor
  class InvalidIpError < StandardError; end

  module IpNormalizer
    Result = Struct.new(:version, :value)

    IPV6_HEX_WIDTH = 32

    module_function

    # Returns a Result with:
    #   version: :ipv4 or :ipv6
    #   value:   Integer (0..2**32-1) for ipv4, zero-padded 32-char lowercase
    #            hex String for ipv6 -- the same representation IPRange uses
    #            for its ipv4_from/to and ipv6_from/to columns, so callers can
    #            compare/query directly against it.
    def normalize(ip)
      raise InvalidIpError, "ip is blank" if ip.nil? || ip.to_s.strip.empty?

      address = parse(strip_zone_id(ip.to_s.strip))
      address = address.native if address.ipv4_mapped?

      if address.ipv4?
        Result.new(:ipv4, address.to_i)
      else
        Result.new(:ipv6, address.to_i.to_s(16).rjust(IPV6_HEX_WIDTH, "0"))
      end
    end

    def parse(ip)
      IPAddr.new(ip)
    rescue IPAddr::Error => e
      raise InvalidIpError, "#{ip.inspect} is not a valid IP address (#{e.message})"
    end

    # A zone ID (e.g. "fe80::1%eth0") is only meaningful for scoping a link-local
    # address to a network interface -- IPAddr#to_i folds it into the integer
    # value in a way that no longer represents the plain 128-bit address, so it
    # must be dropped before converting to our lookup representation.
    def strip_zone_id(ip)
      ip.sub(/%.*\z/, "")
    end
  end
end
