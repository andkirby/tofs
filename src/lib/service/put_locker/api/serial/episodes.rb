require 'html_entry'
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
      #
      def fetch(url)
        # list = cacher.get 'list-' + url
        # return list if nil != list

        fetcher              = HtmlEntry::PageFetcher.new
        fetcher.instructions = instructions

        list = fetcher.fetch(get_document(url))

        cacher.put 'list-' + url, list, cache_default_namespace

        list
      end

      # protected

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
          block:  {
            selector: '.videosContainer a'
          },
          entity: [
            {
              selector: '.mli-info h2',
              data:     {
                label: {}
              }
            },
            {
              selector: 'a',
              data:     {
                type:      :attribute,
                attribute: 'href'
              }
            },
            {
              selector: '.thumb',
              data:     {
                thumbnail: {
                  type:      :attribute,
                  attribute: 'src'
                }
              }
            },
            {
              selector: '.mli-quality',
              data:     {
                quality: {}
              }
            },
            {
              selector: '.seacsonInfo span',
              data:     {
                number: {}
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
        'episodes'
      end

      # Declare included module functions
      module_function :cacher, :cache_basename, :cache_default_namespace
    end
  end
end
