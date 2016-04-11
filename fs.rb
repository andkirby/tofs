require 'pp'
require 'highline/import'
require 'colorize'

require_relative 'lib/service/fs2_ua/api/category/genres'
require_relative 'lib/shell/output'

module Fs2
  module_function

  def run
    Shell::Output::simple Service::Fs2Ua::get_base_url

    # choose menu
    menu_item = request_menu_item
    menu_item = request_genre(menu_item) || menu_item

    url = Service::Fs2Ua::get_base_url + menu_item[:url]

    pp url

  end

  def request_menu_item
    menu = Service::Fs2Ua::Api::Category::Menu.new
    Shell::Output::simple 'Categories:'.green
    menu_list = menu.fetch_linear
    menu_list.each { |i, el|
      Shell::Output::simple el[:id].to_s + ': ' + el[:label]
    }
    id = reask('Which section?', menu_list.keys.to_s).to_i
    menu_list[id]
  end

  def request_genre(menu_item)
    genres = Service::Fs2Ua::Api::Category::Genres.new
    genres_list = genres.fetch
    i = 0
    genres_list[menu_item[:url]].each { |el|
      i += 1
      Shell::Output::simple i.to_s + ': ' + el[:label]
    }
    values = ([*1..i]|['']).to_s
    key = reask('Which genre?', values)
    genres_list[menu_item[:url]][key.to_i - 1] if '' != key && key
  end

  def reask(question, answers)
    Shell::Output::simple ''
    Shell::Output::simple question.yellow
    input = ask '> '
    unless answers && answers.include?(input)
      input = reask question, answers
    end
    input
  end
end

Fs2::run
