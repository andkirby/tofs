require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../shell/output'
require_relative '../../../api/request'
require_relative '../../../document'
require_relative '../../../fs2_ua'
require 'uri'

module Service
  module Fs2Ua
    module Api
      module Category
        class Menu
          def fetch
            cacher = Service::Api::Cacher.new({:base_name => Service::Fs2Ua::HOSTNAME})
            menu   = cacher.get 'menu', 'menu'
            return menu if nil != menu

            # fetch
            html    = Service::Document::fetch(
              Service::Fs2Ua::get_base_url, true
            )
            fetcher = HtmlReader::PageFetcher.new
            fetcher.set_instructions self::get_menu_instructions
            menu = fetcher.fetch(html)

            cacher.put 'menu', menu, 'menu'

            menu
          end

          protected

          def get_menu_instructions
            {
              :block  => {
                :selector => 'div.b-header__menu'
              },
              :entity => [
                {
                  :xpath => 'div/a',
                  :data  => {
                    :label => {},
                    :url   => {
                      :type      => :attribute,
                      :attribute => 'href',
                    }
                  }
                },
                {
                  :xpath => 'div/a/following-sibling::div',
                  :data  => {
                    :_children => {
                      :type         => :children,
                      :instructions => :the_same
                    },
                  },
                }
              ],
            }
          end
        end
      end
    end
  end
end
