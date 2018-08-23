require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../shell/output'
require_relative '../../../api/request'
require_relative '../../../document'
require_relative '../../../bmovies'
require_relative '../../../bmovies/api/cached'
require_relative 'menu_linear'
require 'uri'
require 'pp'

module Service
  module Bmovies
    module Api
      module Category
        class Menu
          include Service::Bmovies::Api::Cached
          include MenuLinear

          @use_cache = true

          def fetch(use_cache: @use_cache)
            if use_cache
              menu = cacher.get 'menu', 'menu'
              return menu if nil != menu
            end

            # fetch
            html = Service::Document::fetch Service::Bmovies::get_base_url, use_cache: use_cache

            fetcher = HtmlReader::PageFetcher.new
            fetcher.instructions = self::menu_instructions
            menu = fetcher.fetch(html)

            cacher.put 'menu', menu, 'menu'

            menu
          end

          def menu_instructions
            {
                # block where entities can be found
                :block        => {
                    :type     => :selector,
                    :selector => "#menu/li:has(ul)",
                },
                :entity => [
                    {
                        :xpath => 'a',
                        :data  => {
                            :label => {},
                            :url   => {
                                :type      => :attribute,
                                :attribute => 'href',
                            },
                        }
                    },
                    # instruction for child nodes
                    {
                        :xpath => 'a/following-sibling::ul/li',
                        :gather_data => true,
                        :data => {
                            :_children => {
                                :type      => :children,
                                :instructions => :the_same
                            },
                        },
                    }
                ],
            }
          end

          def get_cache_default_namespace
            'menu'
          end
        end
      end
    end
  end
end
