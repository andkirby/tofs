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
      module Item
        class Slider
          include Service::Bmovies::Api::Cached

          @use_cache = false

          def fetch(use_cache: @use_cache)
            if use_cache
              items = cacher.get 'item', get_cache_default_namespace
              return items if nil != items
            end

            # fetch
            html = Service::Document::fetch Service::Bmovies::get_base_url, use_cache: use_cache

            fetcher              = HtmlReader::PageFetcher.new
            fetcher.instructions = self::menu_instructions
            items                 = fetcher.fetch(html)

            cacher.put 'items', items, get_cache_default_namespace

            items
          end

          def menu_instructions
            {
                # block where entities can be found
                :block  => {
                    :type     => :selector,
                    :selector => '.slider.swiper-container div.container > div.inner',
                },
                :entity => [
                    {
                        :selector => 'a.name',
                        :data => {
                            :label => {},
                            :url   => {
                                :type      => :attribute,
                                :attribute => 'href',
                            },
                        }
                    },
                    {
                        :selector => '.meta .imdb > b',
                        :data => {
                            :imdb => {},
                        }
                    },
                    {
                        :selector => '.meta .quality',
                        :data => {
                            :quality => {},
                        }
                    },
                    {
                        :selector => '.meta .category',
                        :gather_data => true,
                        :data => {
                            :genre => {
                                :type      => :children,
                                :instructions => {
                                    :selector => 'a',
                                    :data => {
                                        :label   => {},
                                        :url   => {
                                            :type      => :attribute,
                                            :attribute => 'href',
                                        },
                                    }
                                }
                            },
                        }
                    },
                    {
                        :selector => '.desc',
                        :data => {
                            :description => {},
                        }
                    },
                ],
            }
          end

          def get_cache_default_namespace
            'slider'
          end
        end
      end
    end
  end
end
