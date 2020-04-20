# frozen_string_literal: true

require 'dotenv/load'
include TTY::Color

def start
  ARGV.each do |a|
    params = a.split(':')
    ARGUMENTS[params[0]] = params[1]
    puts "Entered: #{params[0]}"
  end
  ARGV.clear
  include TTY::Color

  # get_repos_with_paging("https://api.github.com/users/#{ARGUMENTS['username']}/repos?per_page=100")
  main_menu
end

def filter_repos
  print_options
  handle_input(request_input)
end

def print_repos(repos)
  repos.each do |repo|
    puts "\n#{repo['full_name']}"
    puts repo['html_url']
  end
  puts "Total: #{repos.size}"
end

def print_options
  prompt = TTY::Prompt.new
  choices = [
    { key: 'r', name: 'View available repos', value: :pr },
    { key: 'f', name: 'View filtered repos', value: :pfr },
    { key: 'd', name: 'Delete single repo', value: :dr }
  ]
  print TTY::Box.frame(
    align: :center, padding: [1, 10, 1, 10]
  ) {
          "AVAILABLE OPTIONS"
        }
  input =
    prompt.select('', help: "'e' to exit program", symbols: { marker: '->' }) do |menu|
      menu.choice 'View available repos', "pr", key: "pr"
      menu.choice 'View filtered repos', "pfr"
      menu.choice 'Delete single repo', "dr"
      menu.choice 'Filter repos', "fr"
      menu.choice 'Remove selected repos', "dfr"
      menu.choice 'Remove all repos (Dangerous)', "dar"
      menu.choice 'Exit program', "exit", 'e'
    end
  puts "Selected: #{input}"
  input
  # puts 'print-repos/pr              : View available repos'
  # puts 'pfr/pf-repos                : View filtered repos'
  # puts 'dr/ del-repo                : Delete a single repo'
  # puts 'frepo/fr                    : Filters repos before removing them from github'
  # puts 'del-f-repos/del-fr          : Will delete all filtered repos'
  # puts 'del-all-repos               : Will delete all repos (Dangerous)'
  # puts 'exit/e                      : Exits program'
  # puts "\n********************************************"
end

def main_menu
  input = print_options
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
  when 'fr', 'frepo'
    get_filter_key
  when "dr", "del-repo"
    get_repo_url_input
  when "del-f-repos", "del-fr"
    confirm_delete_filtered_repos
  when 'exit', 'e'
    abort('Goodbye')
  else
    puts 'Not a valid option'
    main_menu
  end
end

def print_confirm_delete_repos
  print_repos(ARGUMENTS["select_repos"])
  puts "-------------------------------------"
  puts "|               WARNING             |"
  puts "-------------------------------------"
  puts "You are going to permanently delete #{ARGUMENTS['select_repos'].size}"
  puts "-------------------------------------"
  puts "|               Confirm              |"
  puts "-------------------------------------"
  puts "yes/y or no/n to return to main menu"
end

def confirm_delete_filtered_repos
  print_confirm_delete_repos
  input = gets.chomp

  case input
  when 'yes', 'y'
    handle_delete_repos(ARGUMENTS['select_repos'])
  when 'no', 'n'
    main_menu
  else
    puts "Invalid option"
    confirm_delete_filtered_repos
  end
end

def handle_delete_repos(repos)
  repos.each do |repo|
    remove_repo(repo["full_name"])
  end
  main_menu
end

def get_filter_key
  puts "\n*********************************************************"
  puts "-----------------------------------------------------------"
  puts "|                         FILTER REPOS                    |"
  puts "-----------------------------------------------------------"
  puts "Enter'c' to cancel and return to main menu: \n\n"
  puts "Enter keywords to filter repos. i.e. user, ruby, 05191990, april"

  input = gets.chomp
  main_menu if input == 'cancel'
  handle_repo_filter(input)
end

def handle_repo_filter(key)
  ARGUMENTS['select_repos'] =
    ARGUMENTS['repos'].select do |repo|
      repo['full_name'].include?(key)
    end
  print_repos(ARGUMENTS['select_repos'])
  main_menu
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
    main_menu
  when "no", "n"
    get_repo_url_input
  when "cancel"
    main_menu
  else
    puts "Not a valid option"
    get_repo_url_input
  end
end
