require "rails_helper"

RSpec.describe Hvor::Importer do
  let(:ipv4_zip) { File.open(Rails.root.join("../fixtures/files/db1_lite_ipv4_sample.zip")) }
  let(:ipv6_zip) { File.open(Rails.root.join("../fixtures/files/db1_lite_ipv6_sample.zip")) }

  after do
    ipv4_zip.close
    ipv6_zip.close
  end

  it "imports both files' rows" do
    described_class.new.import(ipv4_zip: ipv4_zip, ipv6_zip: ipv6_zip)

    expect(Hvor::IPRange.ipv4.count).to eq(3)
    expect(Hvor::IPRange.ipv6.count).to eq(2)
    expect(Hvor::IPRange.lookup_country_code("1.0.0.5")).to eq("AU")
    expect(Hvor::IPRange.lookup_country_code("8.8.8.8")).to eq("US")
  end

  it "dumps and repopulates rather than appending on repeated imports" do
    described_class.new.import(ipv4_zip: ipv4_zip, ipv6_zip: ipv6_zip)
    ipv4_zip.rewind
    ipv6_zip.rewind

    described_class.new.import(ipv4_zip: ipv4_zip, ipv6_zip: ipv6_zip)

    expect(Hvor::IPRange.count).to eq(5)
  end

  it "leaves existing data untouched if either file fails to parse before the transaction opens" do
    Hvor::IPRange.create!(ip_version: :ipv4, ipv4_from: 0, ipv4_to: 1, country_code: "ZZ")
    broken_zip = Tempfile.new("broken").tap { |f| f.write("not a zip") }.tap(&:rewind)

    expect do
      described_class.new.import(ipv4_zip: ipv4_zip, ipv6_zip: broken_zip)
    end.to raise_error(Zip::Error)

    expect(Hvor::IPRange.count).to eq(1)
    expect(Hvor::IPRange.first.country_code).to eq("ZZ")
  ensure
    broken_zip&.close!
  end
end
