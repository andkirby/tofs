require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../service/document'
require_relative '../../../../service/put_locker'
require_relative '../../../../service/put_locker/api/cached'

module Service::PutLocker::Serial
  module Seasons
    module_function
    include Service::PutLocker::Api::Cached

    ##
    # Fetch seasons and serials presented on the page
    #
    # @param [String] url   Base season page URL
    # @return [Array]
    #
    def fetch(url)
      list = get_cacher.get 'list-' + url
      return list if nil != list

      fetcher = HtmlReader::PageFetcher.new
      fetcher.set_instructions self::get_instructions
      list = fetcher.fetch(get_document(url))

      get_cacher.put 'list-' + url, list

      list
    end

    protected

    def get_document(url)
      Service::Document::fetch(url)
    end

    def get_instructions
      {
        :block  => {
          :selector => 'div.content-box'
        },
        :entity => [
          {
            # :selector => 'h2 a.selector_name',
            :selector => 'h2:has(a)',
            :data     => {
              :season => {},
            }
          },
          {
            # :xpath => 'h2[a[@class="selector_name"]]/following-sibling::table',
            :selector => 'h2:has(a) + table',
            :data     => {
              :series => {
                :type         => :children,
                :instructions => [
                  {
                    :selector => 'td a',
                    :data     => {
                      :url          => {:type => :attribute, :attribute => 'href'},
                      :season_label => {},
                    },
                  }]
              }
            },
          },
        ],
      }
    end

    def get_cache_options
      {:timeout => 3600}
    end

    ##
    # Get default namespace
    #
    # @return [String]

    def get_cache_default_namespace
      'seasons'
    end

    # module_function :get_cacher, :get_cache_basename, :get_cache_default_namespace,
    #                 :get_cache_options, :get_instructions, :get_document
  end
end
