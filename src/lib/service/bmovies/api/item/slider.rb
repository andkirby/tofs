require 'html_entry'
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
              items = cacher.get 'item', cache_default_namespace
              return items unless items.nil?
            end

            # fetch
            html = document(use_cache)

            fetcher              = HtmlEntry::PageFetcher.new
            fetcher.instructions = instructions

            items = fetcher.fetch(html)

            cacher.put 'items', items, cache_default_namespace

            items
          end

          def instructions
            {
              # block where entities can be found
              block:  {
                type:     :selector,
                selector: '.slider.swiper-container div.container > div.inner'
              },
              entity: [
                {
                  selector: 'a.name',
                  data:     {
                    label: {},
                    url:   {
                      type:      :attribute,
                      attribute: 'href'
                    }
                  }
                },
                {
                  selector: '.meta .imdb > b',
                  data:     {
                    imdb: {}
                  }
                },
                {
                  selector: '.meta .quality',
                  data:     {
                    quality: {}
                  }
                },
                {
                  selector:    '.meta .category',
                  merge: true,
                  data:        {
                    genre: {
                      type:         :children,
                      instructions: {
                        selector: 'a',
                        data:     {
                          label: {},
                          url:   {
                            type:      :attribute,
                            attribute: 'href'
                          }
                        }
                      }
                    }
                  }
                },
                {
                  selector: '.desc',
                  data:     {
                    description: {}
                  }
                }
              ]
            }
          end

          def cache_default_namespace
            'slider'
          end

          protected

          def document(use_cache)
            Service::Document.fetch Service::Bmovies.base_url,
                                    use_cache: use_cache
          end
        end
      end
    end
  end
end
