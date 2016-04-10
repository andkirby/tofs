require_relative '../html_reader/page_fetcher'
require_relative '../shell/output'
require_relative 'api/request'
require 'rest_client'
require 'uri'
require 'pp'

module Service
  module Fs2Ua
    HOSTNAME = "\x66\x73\x2E\x74\x6F"

    def get_base_url
      'http://' + HOSTNAME
    end

    def show_menu(menu, level = 0)
      menu.each { |item|
        if item.instance_of? Array
          return show item, level
        end

        prefix = '--' * level

        Shell::Output.simple prefix +
                        ' ' + item[:label] +
                        ' ' + get_base_url + item[:url]

        if item[:_children]
          show(item[:_children], level + 1)
        end
      }
    end

    module_function :get_base_url, :show
  end
end
