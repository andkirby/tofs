require_relative '../html_reader/page_fetcher'
require_relative '../shell/output'
require_relative 'api/request'
require 'rest_client'
require 'uri'
require 'pp'

module Service
  module Bmovies
    module_function

    # current: www7.f.se
    HOSTNAME = "\x77\x77\x77\x37\x2E\x66\x6D\x6F\x76\x69\x65\x73\x2E\x73\x65"

    def get_base_url
      'https://' + HOSTNAME
    end

    def show_menu(menu, level = 0)
      menu.each { |item|
        if item.instance_of? Array
          return show_menu item, level
        end

        prefix = '--' * level

        Shell::Output.simple prefix +
                        ' ' + item[:label] +
                        ' ' + get_base_url + item[:url]

        if item[:_children]
          show_menu(item[:_children], level + 1)
        end
      }
    end
  end
end
