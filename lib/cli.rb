# frozen_string_literal: true

require 'dotenv/load'

def start
  ARGV.each do |a|
    params = a.split(':')
    ARGUMENTS[params[0]] = params[1]
    puts "Argument: #{a}"
  end
  ARGV.clear
  get_repos_with_paging("https://api.github.com/users/#{ARGUMENTS['username']}/repos?per_page=100")
  main_menu
end

def filter_repos
  print_options
  handle_input(request_input)
end

def print_repos(repos)
  repos.each do |repo|
    puts "\n#{repo['name']}"
    puts repo['html_url']
  end
end

def print_options
  puts "\n********************************************"
  puts "AVAILABLE COMMANDS \n"
  puts 'print-repos/pr              : View available repos'
  puts 'pfr/pf-repos                : View filtered repos'
  puts 'dr/ del-repo               : Delete a single repo'
  puts 'frepo/fr             : Filters repos before removing them from github'
  puts 'del-repos-f                 : Will delete all filtered repos'
  puts 'del-all-repos               : Will delete all repos (Dangerous)'
  puts 'exit/e                      : Exits program'
  puts "\n********************************************"
end

def main_menu
  print_options
  input = gets.chomp
  puts "Input: #{input}\n"
  handle_input(input)
end

def handle_input(input)
  case input
  when 'print-repos', 'pr'
    print_repos(ARGUMENTS['repos'])
    main_menu
  when 'pf-repos', 'pfr'
    print_repos(ARGUMENTS['select_repos'])
    main_menu
  when 'frepo', 'fr'
    get_filter_key
  when "dr", "del-repo"
    get_repo_url_input
  when 'exit', 'e'
    abort('Goodbye')
  else
    puts 'Not a valid option'
    main_menu
  end
end

def get_filter_key
  puts "Enter the repo name or 'c' to cancel and return to main menu: \n\n"
  input = gets.chomp
  main_menu if input == 'cancel'
  handle_repo_filter(input)
end

def handle_repo_filter(value)
  ARGUMENTS['select_repos'] =
    ARGUMENTS['repos'].select do |repo|
      binding.pry
      repo["name"]
    end
end

def get_repo_url_input
  puts "Enter the repo name or 'c' to cancel and return to main menu: \n\n"
  input = gets.chomp
  main_menu if input == 'cancel'
  handle_repo_delete(input)
end

def handle_repo_delete(repo_name)
  puts "#{repo_name} WILL BE DELETED \n"
  puts " #{repo_name}"
  puts "\nConfirm? yes/no : y/n"
  puts "Enter 'cancel' to return to main menu\n\n"
  input = gets.chomp
  case input
  when "yes", "y"
    remove_repo(repo_name)
  when "no", "n"
    get_repo_url_input
  when "cancel"
    main_menu
  else
    puts "Not a valid option"
    get_repo_url_input
  end
end
