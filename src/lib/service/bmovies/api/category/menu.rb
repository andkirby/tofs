require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../shell/output'
require_relative '../../../api/request'
require_relative '../../../document'
require_relative '../../../bmovies'
require_relative '../../../bmovies/api/cached'
require 'uri'
require 'pp'

module Service
  module Bmovies
    module Api
      module Category
        class Menu
          include Service::Bmovies::Api::Cached

          def fetch
            # menu = get_cacher.get 'menu', 'menu'
            # return menu if nil != menu


            # fetch
            html = Service::Document::fetch(
                Service::Bmovies::get_base_url, true
            )
            fetcher = HtmlReader::PageFetcher.new
            fetcher.set_instructions self::get_menu_instructions
            menu = fetcher.fetch(html)

            get_cacher.put 'menu', menu, 'menu'

            menu
          end

          def fetch_linear(use_cache = true)

            # if use_cache
            #   menu = get_cacher.get 'menu-linear', 'menu' if use_cache
            #   return menu if nil != menu
            # end

            menu = get_linear_menu(fetch)
            get_cacher.put 'menu-linear', menu, 'menu' if use_cache

            menu
          end

          protected

          def get_linear_menu(menu, parent_name = '', level = 0, count = 0)
            result = {}
            menu.each {|item|
              if item.instance_of? Array
                return show item, level
              end

              if level > 0
                count += 1
                result[count] = {
                    :id => count,
                    :label => parent_name.to_s + '/' + item[:label],
                    :url => item[:url]
                }
              end

              if item[:_children]
                result = result.merge(
                    get_linear_menu(
                        item[:_children], item[:label], level + 1, result.count
                    )
                )
              end
            }
            result
          end

          def get_menu_instructions
            {
                # block where entities can be found
                :block        => {
                    :type     => :selector,
                    :selector => '#menu/li',
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
