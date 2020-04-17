# frozen_string_literal: true

require 'dotenv/load'

ARGUMENTS = {}

def start
  data = {}
  ARGV.each do |a|
    value = a.split(':')
    ARGUMENTS[value[0]] = value[1]
    puts "Argument: #{a}"
    puts data
  end
  ARGV.clear
  get_repos_with_paging('https://api.github.com/users/rogerprz/repos?per_page=100')
  filter_repos
end

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
end

def filter_repos
  print_options
  handle_input(request_input)
end

def response_data(response)
  return unless response.code == '200'

  data = JSON.parse(response.body)
  data
end

def print_repos
  ARGUMENTS['repos'].each do |repo|
    puts repo['html_url']
  end
end

def print_options
  puts "\n********************************************"
  puts 'Available options'
  puts 'print-repos  : view available repos'
  puts 'print-f-repos: view filtered repos'
  puts 'filter - filters repos before removing them from github'
  puts 'del-repos-f : Will delete all filtered repos'
  puts 'del-all-repos : Will delete all repos (Dangerous)'
  puts 'exit/e : Exits program'
end

def request_input
  input = gets.chomp
  puts "Input: #{input}\n"
  input
end

def handle_input(input)
  case input
  when 'print-repos'
    print_repos
  when 'exit', 'e'
    abort('Goodbye')
  else
    puts 'Not a valid option'
    puts print_options
    handle_input(request_input)
  end
end

