# frozen_string_literal: true

def get_repos(uri)
  escaped_url = URI::DEFAULT_PARSER.escape(uri)
  uri = URI.parse(escaped_url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new(uri)
    request['accept'] = 'application/vnd.github.v3+json'
    request.basic_auth(' ', "Basic #{ARGUMENTS['token']}")
    response = http.request(request)
    { data: response_data(response), header: response.header }
  end
end

def get_repos_with_paging(uri)
  results = []
  page = 1

  escaped_base_url = URI::DEFAULT_PARSER.escape("#{uri}&page=#{page}")
  uri = escaped_base_url.to_s
  response = get_repos(uri)
  results.concat(response.fetch(:data))
  # skip_count = response.fetch(:data).size
  until response.fetch(:data).empty?
    page += 1
    uri = "#{uri}&page=#{page}"
    response = get_repos(uri)
    results.concat(response.fetch(:data))
  end
  puts "Success! We found #{results.size} repos."
  ARGUMENTS['repos'] = results
  ARGUMENTS['select_repos'] = results
end

def response_data(response)
  return unless response.code == '200'

  JSON.parse(response.body)
end

def remove_repo(repo_name)
  puts "\nRemoving: #{repo_name}"
  client = Octokit::Client.new(access_token: (ARGUMENTS['token']).to_s)
  response = client.delete_repository("#{ARGUMENTS['username']}/#{repo_name}")
  if reponse
    puts "Successfully removed #{repo_name}"
  else
    puts "ERROR: Issue occurred repo may have not been deleted."
  end
  response
end
