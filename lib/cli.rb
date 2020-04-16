# frozen_string_literal: true

def get_repos
  escaped_url = URI::DEFAULT_PARSER.escape('https://api.github.com/users/rogerprz/repos')
  uri = URI.parse(escaped_url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new(uri)
    request['accept'] = 'application/vnd.github.v3+json'
    puts ENV[GITHUB_PAT]
    request.basic_auth(' ', ENV[GITHUB_PAT])
    response = http.request(request)
    {
      data: response_data(type, response, collection_key_value),
      headers: response.header
    }
  end
end

def start
  'hello'
end
