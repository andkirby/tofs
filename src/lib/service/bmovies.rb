require 'html_entry'
require_relative '../shell/output'
require_relative 'api/request'
require 'rest_client'
require 'uri'
require 'pp'

module Service
  ##
  # Bmovies endpoint
  #
  module Bmovies
    module_function

    # current: www7.f.se
    HOSTNAME = "\x77\x77\x77\x37\x2E\x66\x6D\x6F\x76\x69\x65\x73\x2E\x73\x65".freeze

    def base_url
      'https://' + HOSTNAME
    end

    # @return [void]
    def show_menu(menu, level = 0)
      menu.each do |item|
        return show_menu item, level if item.instance_of? Array
        prefix = '--' * level
        menu_output(item, prefix)
        show_menu(item[:_children], level + 1) if item[:_children]
      end
    end

    protected

    def menu_output(item, prefix)
      Shell::Output.simple prefix +
                           ' ' + item[:label] +
                           ' ' + base_url + item[:url]
    end
  end
end
