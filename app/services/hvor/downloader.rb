require "net/http"
require "uri"
require "tempfile"

module Hvor
  class DownloadError < StandardError; end

  # Downloads an IP2Location LITE CSV zip archive for the given product code
  # (e.g. "DB1LITECSV", "DB1LITECSVIPV6") and returns it as a Tempfile. The
  # caller is responsible for closing/unlinking the Tempfile.
  class Downloader
    MAX_REDIRECTS = 5

    def initialize(product_code, timeout: Hvor.configuration.download_timeout)
      @product_code = product_code
      @timeout = timeout
    end

    def call
      fetch(download_uri, MAX_REDIRECTS)
    end

    private

    attr_reader :product_code, :timeout

    def download_uri
      URI("https://www.ip2location.com/download?token=#{Hvor.configuration.api_token}&file=#{product_code}")
    end

    def fetch(uri, redirects_left)
      raise DownloadError, "too many redirects downloading #{uri}" if redirects_left < 0

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: timeout, read_timeout: timeout) do |http|
        http.request(Net::HTTP::Get.new(uri)) do |response|
          case response
          when Net::HTTPRedirection
            return fetch(uri + response["location"], redirects_left - 1)
          when Net::HTTPSuccess
            return stream_to_tempfile(response)
          else
            raise DownloadError, "failed to download #{uri}: #{response.code} #{response.message}"
          end
        end
      end
    end

    def stream_to_tempfile(response)
      file = Tempfile.new([ product_code, ".zip" ], binmode: true)
      response.read_body { |chunk| file.write(chunk) }
      file.flush
      file.rewind
      file
    end
  end
end
