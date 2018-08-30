require 'uri'
require 'rest_client'
require_relative 'cacher'

module Service
  module Api
    ##
    # Request module
    #
    module Request
      module_function

      def request(url, use_cache: true, namespace: nil, timeout: 3600)
        cached_execute namespace: namespace,
                       url: url,
                       timeout: use_cache ? timeout : nil
      end

      # protected

      def execute(url)
        String.new(query(url))
      end

      def query(url)
        RestClient.get(url)
      end

      def cached_execute(namespace:, url:, timeout: 3600)
        cacher = cacher timeout, url
        body   = nil
        body   = cacher.get url, namespace unless timeout.nil?
        return body unless body.nil?

        body = execute(url)
        cacher.put url, body, namespace
        body
      end

      def cacher(timeout, url)
        Api::Cacher.new(
          base_name: URI.parse(url).host,
          timeout:   timeout
        )
      end
    end
  end
end
