require 'html_entry'
require_relative '../../../../service/document'
require_relative '../../../../service/put_locker'
require_relative '../../../../service/put_locker/api/cached'

module Service::PutLocker::Api
  module Serial
    module Seasons
      # Include caching methods
      include Service::PutLocker::Api::Cached
      module_function

      ##
      # Fetch seasons and serials presented on the page
      #
      # @param [String] url   Base season page URL
      # @return [Array]
      #
      def fetch(url)
        list = cacher.get 'list-' + url
        return list if nil != list

        fetcher = HtmlEntry::PageFetcher.new
        fetcher.instructions = instructions
        list = fetcher.fetch(get_document(url))

        cacher.put 'list-' + url, list

        list
      end

      protected
      module_function

      def get_document(url)
        Service::Document::fetch(url)
      end

      ##
      # Get fetching instructions
      #
      # @return [Hash]
      #
      def instructions
        {
          :block  => {
            :selector => 'div.content-box'
          },
          :entity => [
            {
              # :selector => 'h2 a.selector_name',
              :selector => 'h2 a:has(strong)',
              :data     => {
                :season       => {},
                :season_url   => {:type => :attribute, :attribute => 'href'},
                :season_index => {
                  :type     => :function,
                  :function => Proc.new { |name, instruction, data, options|
                    /\d+/.match(data[:season]).to_s.to_i
                  },
                },
              }
            },
            {
              # :xpath => 'h2[a[@class="selector_name"]]/following-sibling::table',
              :selector => 'h2:has(a) + table',
              :data     => {
                :episodes => {
                  :type         => :children,
                  :instructions => [
                    {
                      :selector => 'td a',
                      :data     => {
                        :url   => {:type => :attribute, :attribute => 'href'},
                        :label => {},
                        :index => {
                          :type     => :function,
                          :function => Proc.new { |name, instruction, data, options|
                            /\d+/.match(data[:label]).to_s.to_i
                          },
                        },
                      },
                    }]
                }
              },
            },
          ],
        }
      end

      def cache_options
        {:timeout => 3600}
      end

      ##
      # Get default namespace
      #
      # @return [String]
      #
      def cache_default_namespace
        'seasons'
      end

      # Declare included module functions
      module_function :cacher, :cache_basename
    end
  end
end
