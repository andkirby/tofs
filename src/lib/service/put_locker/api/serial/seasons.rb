require 'html_entry'
require_relative '../../../../service/document'
require_relative '../../../../service/put_locker'
require_relative '../../../../service/put_locker/api/cached'

module Service
  module PutLocker
    module Api
      module Serial
        ##
        # Seasons data model
        #
        class Seasons
          # Include caching methods
          include Service::Api::Cached
          include Service::PutLocker::Api::Cached

          ##
          # Fetch seasons and serials presented on the page
          #
          # @param [String] url   Base season page URL
          # @return [Array]
          #
          def fetch(url)
            list = cacher.get 'list-' + url
            return list unless list.nil?

            fetcher              = HtmlEntry::PageFetcher.new
            fetcher.instructions = instructions
            list                 = fetcher.fetch(get_document(url))

            cacher.put 'list-' + url, list

            list
          end

          protected

          def get_document(url)
            Service::Document.fetch(url)
          end

          ##
          # Get fetching instructions
          #
          # @return [Hash]
          #
          def instructions
            {
              block: {
                selector: 'div.content-box'
              },
              entity: [
                {
                  # :selector => 'h2 a.selector_name',
                  selector: 'h2 a:has(strong)',
                  data: {
                    season: {},
                    season_url: { type: :attribute, attribute: 'href' },
                    season_index: {
                      type: :function,
                      function: proc do |_name, _instruction, data, _options|
                        /\d+/.match(data[:season]).to_s.to_i
                      end
                    }
                  }
                },
                {
                  # :xpath => 'h2[a[@class="selector_name"]]/following-sibling::table',
                  selector: 'h2:has(a) + table',
                  data: {
                    episodes: {
                      type: :children,
                      instructions: [
                        {
                          selector: 'td a',
                          data: {
                            url: { type: :attribute, attribute: 'href' },
                            label: {},
                            index: {
                              type: :function,
                              function: proc do |_name, _instruction, data, _options|
                                /\d+/.match(data[:label]).to_s.to_i
                              end
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              ]
            }
          end

          def cache_options
            { timeout: 3600 }
          end

          ##
          # Get default namespace
          #
          # @return [String]
          #
          def cache_default_namespace
            'seasons'
          end
        end
      end
    end
  end
end
