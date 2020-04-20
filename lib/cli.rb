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
  print_welcome
  get_repos_with_paging("https://api.github.com/users/#{ARGUMENTS['username']}/repos?per_page=100")
  main_menu
end

def main_menu
  input = print_options
  puts "Selected: #{input}\n"
  handle_input(input)
end

def print_options
  prompt = TTY::Prompt.new
  print TTY::Box.frame(
    align: :center, padding: [1, 10, 1, 10], title: { top_left: 'Github', bottom_right: '@rogerprz' }
  ) { "AVAILABLE OPTIONS" }
  input =
    prompt.select('', symbols: { marker: '->' }) do |menu|
      menu.choice 'View available repos - pr', "pr", key: "pr"
      menu.choice 'View filtered repos - pfr', "pfr", key: "pfr"
      menu.choice 'Filter repos', "fr"
      menu.choice 'Select multiple repos to remove', 'mrd'
      menu.choice 'Delete single repo', "dr"
      menu.choice 'Remove selected repos', "dfr"
      menu.choice 'Remove all repos (Dangerous)', "dar"
      menu.choice 'Exit program', "exit", key: 'e'
    end
  input
end

def filter_repos
  handle_input(print_options)
end

def print_repos(repos)
  repos.each do |repo|
    puts TTY::Link.link_to((repo['full_name']).to_s, repo['html_url'])
  end
  puts "Total: #{repos.size}"
end

def handle_input(input)
  case input
  when 'pr'
    print_repos(ARGUMENTS['repos'])
    main_menu
  when 'pfr'
    print_repos(ARGUMENTS['select_repos'])
    main_menu
  when 'fr'
    filter_key
  when 'mrd'
    select_multiple_repos
  when "dr"
    get_repo_url_input
  when 'dfr'
    confirm_filtered_repo_removal(ARGUMENTS['select_repos'])
  when 'exit', 'e'
    abort('Goodbye')
  else
    puts 'Not a valid option'
    main_menu
  end
end

def select_multiple_repos
  prompt = TTY::Prompt.new
  repos = ARGUMENTS['repos'].map { |repo| repo['full_name'] }
  results = prompt.multi_select('Select the repos you would like to remove', repos)
  puts results
  confirm_filtered_repo_removal(results)
end

def print_confirm_delete_repos(repos)
  print_repos(repos)
  print TTY::Box.frame(
    align: :center, padding: [1, 10, 1, 10], title: { top_left: 'Github', bottom_right: '@rogerprz' }
  ) {
    "WARNING \n
    You are going to permanently remove #{repos.size} repos. \n
    CONFIRM\n
    yes/y or no/n to return to main menu"
  }
end

def confirm_filtered_repo_removal(repos)
  print_confirm_delete_repos(repos)
  input = gets.chomp

  case input
  when 'yes', 'y'
    handle_repo_removal(repos)
  when 'no', 'n'
    main_menu
  else
    puts "Invalid option"
    confirm_filtered_repo_removal
  end
end

def handle_repo_removal(repos)
  repos.each do |repo|
    repo_name = repo["full_name"] || repo
    remove_repo(repo_name)
  end
  main_menu
end

def filter_key
  print_filter_key
  puts "Enter filter key: "
  input = gets.chomp
  main_menu if input == 'c'
  handle_repo_filter(input)
end

def print_filter_key
  print TTY::Box.frame(
    align: :center, padding: [1, 10, 1, 10], title: { top_left: 'Github', bottom_right: '@rogerprz' }
  ) {
    "FILTER REPOS \n
    Enter'c' to cancel and return to main menu: \n
    Enter keywords to filter repos. i.e. user, ruby, 05191990, april"
  }
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
