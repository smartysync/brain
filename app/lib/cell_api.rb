class CellApi
  def initialize(cell:)
    @cell = cell
  end

  def accept_block_devices(block_devices:)
    request path:    "/admin-api/v1/block-devices",
            method:  :patch,
            payload: {
              block_devices: Hash[
                block_devices.map do |block_device|
                  [block_device, status: :accepted]
                end
              ]
            }
  end

  def sync_object(sync_token:)
    request path:    "/admin-api/v1/objects",
            method:  :post,
            payload: {
              sync_token: sync_token.token
            }
  end

  def request(path:, method: :get, payload: nil, query: nil, access_token: nil)
    response = perform_request path: path, method: method, payload: payload, query: query,
                               access_token: access_token
    json_response = begin
                      JSON.parse response.body, symbolize_names: true
                    rescue JSON::ParserError
                      nil
                    end
    return response, json_response unless block_given?
    yield response, json_response
  end

  def perform_request(path:, method:, payload:, query:, access_token:)
    uri = URI("http://#{@cell.ip_address}#{path}")
    uri.query = URI.encode_www_form(query) if query
    http = Net::HTTP.new uri.host, uri.port
    req = build_request uri: uri, method: method
    req["Authorization"] = "Bearer #{access_token}" if access_token
    req.body = payload.to_json if !%i[head get delete].include?(method) && payload
    http.request req
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def build_request(uri:, method:)
    case method
    when :head   then Net::HTTP::Head.new   uri.request_uri
    when :get    then Net::HTTP::Get.new    uri.request_uri
    when :post   then Net::HTTP::Post.new   uri.request_uri, "Content-Type" => "application/json"
    when :put    then Net::HTTP::Put.new    uri.request_uri, "Content-Type" => "application/json"
    when :patch  then Net::HTTP::Patch.new  uri.request_uri, "Content-Type" => "application/json"
    when :delete then Net::HTTP::Delete.new uri.request_uri
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
