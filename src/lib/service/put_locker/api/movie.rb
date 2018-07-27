require_relative '../../../html_reader/page_fetcher'
require_relative '../../../html_reader/page/entity_fetcher'
require_relative '../../../service/document'
require_relative '../../../service/put_locker'
require_relative '../../../service/put_locker/api/cached'

module Service
  module PutLocker
    module Api
      module Movie
        module_function

        # Include caching methods
        include Service::PutLocker::Api::Cached

        ##
        # Fetch movie info
        #
        # @param [String] url   Base season page URL
        # @return [Hash]

        def fetch_info(url)
          info = get_cacher.get 'info-' + url
          return info if nil != info

          fetcher = HtmlReader::PageFetcher.new
          # TODO add fetching genres
          fetcher.set_instructions(
            {
              :block  => {
                :selector => 'div.content-box td.summary > table.table2'
              },
              :entity => [
                {
                  :selector => 'h2 a',
                  :data     => {
                    :label => {},
                    :url   => {:type => :attribute, :attribute => 'href'},
                  }
                }
              ]
            }
          )
          info = fetcher.fetch(get_document(url))
          return nil unless info

          info = info.first
          get_cacher.put 'info-' + url, info

          info
        end

        protected
        module_function

        def get_document(url)
          Service::Document::fetch(url)
        end

        def get_cache_options
          {:timeout => 3600 * 24 * 365}
        end

        ##
        # Get default namespace
        #
        # @return [String]

        def get_cache_default_namespace
          'movie'
        end

        # Declare included module functions
        module_function :get_cacher, :get_cache_basename
      end
    end
  end
end
