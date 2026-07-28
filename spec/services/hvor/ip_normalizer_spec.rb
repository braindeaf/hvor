require "rails_helper"

RSpec.describe Hvor::IpNormalizer do
  describe ".normalize" do
    it "normalizes a plain ipv4 address" do
      result = described_class.normalize("1.0.0.1")
      expect(result.version).to eq(:ipv4)
      expect(result.value).to eq(16_777_217)
    end

    it "normalizes a plain ipv6 address to a zero-padded 32-char hex string" do
      result = described_class.normalize("2001:db8::1")
      expect(result.version).to eq(:ipv6)
      expect(result.value).to eq("20010db8000000000000000000000001")
      expect(result.value.length).to eq(32)
    end

    it "unwraps an ipv4-mapped ipv6 address to plain ipv4" do
      result = described_class.normalize("::ffff:1.2.3.4")
      expect(result.version).to eq(:ipv4)
      expect(result.value).to eq(IPAddr.new("1.2.3.4").to_i)
    end

    it "strips a zone id before computing the ipv6 value" do
      with_zone = described_class.normalize("fe80::1%eth0")
      without_zone = described_class.normalize("fe80::1")
      expect(with_zone.value).to eq(without_zone.value)
    end

    it "raises Hvor::InvalidIpError for blank input" do
      expect { described_class.normalize("") }.to raise_error(Hvor::InvalidIpError)
      expect { described_class.normalize(nil) }.to raise_error(Hvor::InvalidIpError)
    end

    it "raises Hvor::InvalidIpError for garbage input" do
      expect { described_class.normalize("definitely-not-an-ip") }.to raise_error(Hvor::InvalidIpError)
    end
  end
end
