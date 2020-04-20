# frozen_string_literal: true

def print_welcome
  link = TTY::Link.link_to(
    '@rogerprz',
    "https://github.com/rogerprz"
  )
  print TTY::Box.frame(
    align: :center,
    padding: [1, 10, 1, 10],
    title: {
      top_left: 'Github',
      bottom_right: '@rogerprz'
    }
  ) {
          "WELCOME TO GITHUB REPO CLEANUP CLI"
        }
end
