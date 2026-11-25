require "json"
require "net/http"
require "uri"

class GooglePlacesSearch
  ENDPOINT = URI("https://places.googleapis.com/v1/places:searchText")

  FIELD_MASK = [
    "places.id",
    "places.displayName",
    "places.formattedAddress",
    "places.googleMapsUri"
  ].join(",")

  def initialize(nomikai)
    @nomikai = nomikai
  end

  def call
    places = search_places(RestaurantSearchIntent.new(@nomikai).call)
    save_candidates(places)
    candidates = candidates_by_place_id

    places.map { |place| present(place, candidates.fetch(place.fetch("id"))) }
  end

  private

  def search_places(query)
    response = post(build_request(query))
    raise "Google Places request failed (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).fetch("places", [])
  end

  def build_request(query)
    request = Net::HTTP::Post.new(ENDPOINT)
    request["Content-Type"] = "application/json"
    request["X-Goog-Api-Key"] = ENV.fetch("GOOGLE_MAPS_API_KEY")
    request["X-Goog-FieldMask"] = FIELD_MASK
    request.body = JSON.generate(textQuery: query, includedType: "restaurant", maxResultCount: 10)
    request
  end

  def post(request)
    Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true, open_timeout: 5, read_timeout: 20) do |http|
      http.request(request)
    end
  end

  def save_candidates(places)
    @nomikai.with_lock do
      places.each do |place|
        venue = Venue.find_or_create_by!(google_place_id: place.fetch("id"))
        @nomikai.candidates.find_or_create_by!(venue: venue)
      end
    end
  end

  def candidates_by_place_id
    @nomikai.candidates.includes(:venue).index_by { |candidate| candidate.venue.google_place_id }
  end

  def present(place, candidate)
    {
      candidate_id: candidate.id,
      selected: candidate.selected?,
      google_place_id: place.fetch("id"),
      name: place.dig("displayName", "text"),
      address: place["formattedAddress"],
      google_maps_uri: place["googleMapsUri"]
    }
  end
end
