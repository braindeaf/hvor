module Hvor
  class LookupsController < ApplicationController
    def show
      render_lookup(params[:ip])
    end

    def me
      render_lookup(request.remote_ip)
    end

    private

    def render_lookup(ip)
      render json: { ip: ip, country_code: Hvor.lookup(ip) }
    rescue Hvor::InvalidIpError => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end
