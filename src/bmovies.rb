require 'pp'
require 'highline/import'
require 'colorize'
require 'terminal-table'
require 'word_wrap'

require_relative 'lib/service/bmovies/api/category/menu'
require_relative 'lib/service/bmovies/api/item/slider'
require_relative 'lib/service/bmovies/api/item/movie'
require_relative 'lib/shell/output'

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
  def show_entity(entity, name: nil, max_value_with: 100, max_width: 120)
    rows = []
    entity.each do |key, value|
      if value.kind_of? Hash
        value = value[:label]
      end
      if value.kind_of? Array and value.first.kind_of? Hash and !value.first[:label].nil?
        value = value.collect{|h| h[:label]}.join(", ").to_s
      end
      # words wrap, max 80 symbols
      value = WordWrap.ww value, max_value_with
      rows.push [key, value]
    end

    table = Terminal::Table.new :title => name, :rows => rows, style: {:padding_left => 2, :width => max_width}

    puts table
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
