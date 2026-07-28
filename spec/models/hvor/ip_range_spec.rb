require "rails_helper"
require "socket"

RSpec.describe Hvor::IPRange do
  describe ".lookup_country_code" do
    it "returns nil when the table is empty" do
      expect(described_class.lookup_country_code("1.2.3.4")).to be_nil
    end

    context "with ipv4 ranges" do
      before do
        described_class.create!(ip_version: :ipv4, ipv4_from: 16_777_216, ipv4_to: 16_777_471, country_code: "AU")
        described_class.create!(ip_version: :ipv4, ipv4_from: 134_744_072, ipv4_to: 134_744_072, country_code: "US")
      end

      it "finds the range containing the ip" do
        expect(described_class.lookup_country_code("1.0.0.5")).to eq("AU")
      end

      it "matches a single-address range" do
        expect(described_class.lookup_country_code("8.8.8.8")).to eq("US")
      end

      it "returns nil for an ip below every range" do
        expect(described_class.lookup_country_code("0.0.0.1")).to be_nil
      end

      it "returns nil for an ip above every range" do
        expect(described_class.lookup_country_code("255.255.255.255")).to be_nil
      end
    end

    context "with ipv6 ranges" do
      before do
        described_class.create!(
          ip_version: :ipv6,
          ipv6_from: (2**64 - 1).to_s(16).rjust(32, "0"),
          ipv6_to: (2**65).to_s(16).rjust(32, "0"),
          country_code: "DK"
        )
      end

      it "finds the range containing the ip" do
        target = (2**64).to_s(16).rjust(32, "0")
        ip = IPAddr.new(target.to_i(16), Socket::AF_INET6).to_s
        expect(described_class.lookup_country_code(ip)).to eq("DK")
      end

      it "returns nil outside the range" do
        expect(described_class.lookup_country_code("::1")).to be_nil
      end
    end

    it "raises Hvor::InvalidIpError for garbage input" do
      expect { described_class.lookup_country_code("not-an-ip") }.to raise_error(Hvor::InvalidIpError)
    end
  end
end
