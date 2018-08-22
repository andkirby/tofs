require 'pp'
require 'highline/import'
require 'colorize'

require_relative 'lib/service/bmovies/api/category/menu'
require_relative 'lib/service/bmovies/api/category/years'
require_relative 'lib/service/bmovies/api/category/genres'
require_relative 'lib/shell/output'

module Bmovies
  module_function

  def run
    Shell::Output::simple Service::Bmovies::get_base_url

    # choose menu
    menu_item = request_menu_item

    url = menu_item[:url]
  end

  def request_menu_item
    Shell::Output::simple 'Categories:'.green

    show_menu Service::Bmovies::Api::Category::Menu.new.fetch
  end

  def show_menu(list)
    ii = 0
    list.each {|el|
      ii += 1
      Shell::Output::simple ii.to_s + ': ' + el[:label]
    }
    values = [*1..ii].map(&:to_s)
    id = reask('Which section?', values).to_i - 1

    return show_menu list[id][:_children] if list[id][:_children]

    list[id]
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
