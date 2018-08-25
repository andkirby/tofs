require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../service/document'
require_relative '../../../../service/put_locker'
require_relative '../../../../service/put_locker/api/cached'

module Service::PutLocker::Api
  module Serial
    module Episodes
      # Include caching methods
      include Service::PutLocker::Api::Cached
      module_function

      ##
      # Fetch seasons and serials presented on the page
      #
      # @param [String] url   Base season page URL
      # @return [Array]

      def fetch(url)
        # list = cacher.get 'list-' + url
        # return list if nil != list

        fetcher              = HtmlReader::PageFetcher.new
        fetcher.instructions = get_instructions
        list                 = fetcher.fetch(get_document(url))

        cacher.put 'list-' + url, list, get_cache_default_namespace

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
      def get_instructions
        {
            :block  => {
                :selector => '.videosContainer a'
            },
            :entity => [
                {
                    :selector => '.mli-info h2',
                    :data     => {
                        :label => {},
                    }
                },
                {
                    :selector => 'a',
                    :data     => {
                        :type      => :attribute,
                        :attribute => 'href',
                    }
                },
                {
                    :selector => '.thumb',
                    :data     => {
                        :thumbnail => {
                            type:      :attribute,
                            attribute: 'src',
                        },
                    }
                },
                {
                    :selector => '.mli-quality',
                    :data     => {
                        :quality => {},
                    }
                },
                {
                    :selector => '.seacsonInfo span',
                    :data     => {
                        :number => {},
                    }
                },
            ]
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
        'episodes'
      end

      # Declare included module functions
      module_function :cacher, :get_cache_basename, :get_cache_default_namespace
    end
  end
end
