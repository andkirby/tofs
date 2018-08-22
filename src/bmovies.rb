require 'pp'
require 'highline/import'
require 'colorize'

require_relative 'lib/service/bmovies/api/category/menu'
require_relative 'lib/service/bmovies/api/item/slider'
require_relative 'lib/service/bmovies/api/item/movie'
require_relative 'lib/shell/output'
require_relative 'lib/service/cli/show_entity'

module Bmovies
  module_function

  def run
    Shell::Output::simple Service::Bmovies::get_base_url

    values = ['Menu', 'Slides', 'Movie']

    choice = choose_menu(values, question: 'Choose entity?')
    case choice
    when 'Menu'
      show_entity request_menu_item
    when 'Slides'
      request_slides.each {|el| show_entity el}
    when 'Movie'
      show_entity request_movie(
                      # '/film/alpha.5kx30/r1x84o'
                      reask('Please input movie URI?', nil).to_s
                  )
    else
      raise "Unknown option: #{choice}."
    end
  end

  def request_slides
    Shell::Output::simple 'Home slides'.green

    Service::Bmovies::Api::Item::Slider.new.fetch
  end

  ##
  # Fetch movie data
  def request_movie(uri)
    Shell::Output::simple 'Movie'.green

    Service::Bmovies::Api::Item::Movie.new.fetch uri: uri
  end

  ##
  # Fetch menu
  def request_menu_item
    Shell::Output::simple 'Menu Categories'.green

    choose_menu Service::Bmovies::Api::Category::Menu.new.fetch, question: 'Which section?'
  end

  def choose_menu(list, question:)
    ii = 0
    list.each {|el|
      ii += 1
      Shell::Output::simple ii.to_s + ': ' +
                                (el.kind_of?(String) ? el : el[:label])
    }
    values = [*1..ii].map(&:to_s)
    id = reask(question, values).to_i - 1

    return choose_menu list[id][:_children], question: question if list[id].kind_of?(Hash) and list[id][:_children]

    list[id]
  end

  ##
  # Show entity data
  def show_entity(*args)
    Service::Cli::ShowEntity::show_entity *args
  end

  ##
  # Ask question in command line
  #
  # @param [String] question
  # @param [Array] answers
  # @param [True, False] show_values
  # @param [Integer] failures
  #
  def reask(question, answers, show_values = false, failures = 3)
    Shell::Output::simple question.yellow
    Shell::Output::simple '(' + answers.join(', ') + ')' if show_values
    input = ask '> '

    return input unless answers

    unless answers && answers.include?(input)
      failures -= 1
      if failures < 1
        raise 'error: Sorry, could not get proper answer.'
      end
      input = reask question, answers, show_values, failures
    end
    input
  end
end

Bmovies::run
