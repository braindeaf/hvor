require "rails_helper"

RSpec.describe "Hvor lookups", type: :request do
  before do
    Hvor::IPRange.create!(ip_version: :ipv4, ipv4_from: 16_777_216, ipv4_to: 16_777_471, country_code: "AU")
    Hvor::IPRange.create!(ip_version: :ipv4, ipv4_from: 2_130_706_432, ipv4_to: 2_130_706_687, country_code: "ZZ")
  end

  describe "GET /hvor/lookup" do
    it "returns the country_code for the given ip" do
      get "/hvor/lookup", params: { ip: "1.0.0.5" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("ip" => "1.0.0.5", "country_code" => "AU")
    end

    it "returns 400 for an invalid ip" do
      get "/hvor/lookup", params: { ip: "not-an-ip" }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to have_key("error")
    end

    it "returns 400 when ip is missing" do
      get "/hvor/lookup"

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "GET /hvor/lookup/me" do
    it "returns the country_code for the requesting client's ip" do
      get "/hvor/lookup/me"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["ip"]).to eq("127.0.0.1")
      expect(body["country_code"]).to eq("ZZ")
    end
  end
end
