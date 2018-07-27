require 'pp'
require 'highline/import'
require 'colorize'

require_relative 'lib/service/fs2_ua/api/category/menu'
require_relative 'lib/service/fs2_ua/api/category/years'
require_relative 'lib/service/fs2_ua/api/category/genres'
require_relative 'lib/shell/output'

module Fs2
  module_function

  def run
    Shell::Output::simple Service::Fs2Ua::get_base_url

    # choose menu
    menu_item = request_menu_item
    case request_genres_or_years?
      when '2'
        menu_item = request_years(menu_item) || menu_item
      when '1'
        menu_item = request_genre(menu_item) || menu_item
      else
    end

    url = Service::Fs2Ua::get_base_url + menu_item[:url]

    puts url

  end

  def request_menu_item
    Shell::Output::simple 'Categories:'.green
    menu_list = Service::Fs2Ua::Api::Category::Menu.new.fetch_linear

    ii = 0
    menu_list.each { |i, el|
      ii += 1
      Shell::Output::simple ii.to_s + ': ' + el[:label]
    }

    values = [*1..ii].map(&:to_s)
    id = reask('Which section?', values).to_i
    menu_list[id]
  end

  def request_genres_or_years?
    Shell::Output::simple 'Filter types:'.green
    Shell::Output::simple '1: Genres'
    Shell::Output::simple '2: Years'
    Shell::Output::simple ' : Skip'
    reask('Filter by genres or years? ', [1, 2, ''].map(&:to_s))
  end

  def request_genre(menu_item)
    Shell::Output::simple 'Genres:'.green
    genres_list = Service::Fs2Ua::Api::Category::Genres.new.fetch
    i = 0
    genres_list[menu_item[:url]].each { |el|
      i += 1
      Shell::Output::simple i.to_s + ': ' + el[:label]
    }
    values = ([*1..i]|['']).map(&:to_s)
    key = reask('Which genre?', values)
    genres_list[menu_item[:url]][key.to_i - 1] if '' != key && key
  end

  def request_years(menu_item)
    Shell::Output::simple 'Years:'.green
    list = Service::Fs2Ua::Api::Category::Years.new.fetch
    i = 0
    list[menu_item[:url]].each { |el|
      i += 1
      Shell::Output::simple i.to_s + ': ' + el[:label]
    }
    values = ([*1..i]|['']).map(&:to_s)
    key = reask('Which year?', values)
    list[menu_item[:url]][key.to_i - 1] if '' != key && key
  end

  ##
  # @param [Array] answers
  def reask(question, answers, show_values = false, failures = 3)
    Shell::Output::simple question.yellow
    Shell::Output::simple '(' + answers.join(', ') + ')' if show_values
    input = ask '> '
    unless answers && answers.include?(input)
      failures -= 1
      if failures < 1
        raise 'error: Could not get proper answer.'
      end
      input = reask question, answers, show_values, failures
    end
    input
  end
end

Fs2::run
