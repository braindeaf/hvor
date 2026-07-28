require "rails_helper"

RSpec.describe Hvor::ImportIpRangesJob do
  let(:ipv4_body) { File.binread(Rails.root.join("../fixtures/files/db1_lite_ipv4_sample.zip")) }
  let(:ipv6_body) { File.binread(Rails.root.join("../fixtures/files/db1_lite_ipv6_sample.zip")) }

  before do
    Hvor.configure { |c| c.api_token = "test-token" }

    stub_request(:get, "https://www.ip2location.com/download?token=test-token&file=DB1LITECSV")
      .to_return(status: 200, body: ipv4_body)
    stub_request(:get, "https://www.ip2location.com/download?token=test-token&file=DB1LITECSVIPV6")
      .to_return(status: 200, body: ipv6_body)
  end

  it "downloads and imports both ip2location files" do
    described_class.perform_now

    expect(Hvor::IPRange.ipv4.count).to eq(3)
    expect(Hvor::IPRange.ipv6.count).to eq(2)
  end

  it "does not run a second import while one is already in flight" do
    Hvor.configuration.cache.write(described_class::LOCK_KEY, true, unless_exist: true)

    described_class.perform_now

    expect(Hvor::IPRange.count).to eq(0)
    expect(a_request(:get, /ip2location/)).not_to have_been_made
  ensure
    Hvor.configuration.cache.delete(described_class::LOCK_KEY)
  end
end
