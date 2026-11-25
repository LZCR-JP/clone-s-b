require "json"
require "net/http"
require "uri"

class GooglePlaceDetails
  BASE_URL = "https://places.googleapis.com/v1/places"

  def initialize(place_id)
    @place_id = place_id
  end

  def call
    return if api_key.blank?

    response = get(build_request)
    return log_failure(response) unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig("displayName", "text")
  rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    Rails.logger.warn("Google Place Details lookup failed: #{e.class}")
    nil
  end

  private

  def api_key
    ENV.fetch("GOOGLE_MAPS_API_KEY", nil)
  end

  def uri
    @uri ||= URI("#{BASE_URL}/#{URI::DEFAULT_PARSER.escape(@place_id)}")
  end

  def build_request
    request = Net::HTTP::Get.new(uri)
    request["X-Goog-Api-Key"] = api_key
    request["X-Goog-FieldMask"] = "displayName"
    request
  end

  def get(request)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.request(request)
    end
  end

  def log_failure(response)
    Rails.logger.warn("Google Place Details failed with HTTP #{response.code}")
    nil
  end
end
