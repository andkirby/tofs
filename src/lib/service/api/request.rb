require 'uri'
require 'rest_client'
require_relative 'cacher'

module Service
  module Api
    module Request
      def request(url, use_cache = true, namespace = nil, timeout = 3600)
        use_cache = false if timeout == 0

        if use_cache
          cacher = Api::Cacher.new(
            {
              :base_name => URI.parse(url).host,
              :timeout => timeout,
            }
          )
          body = cacher.get url, namespace
          return body if nil != body

          body = execute(url)
          cacher.put url, body, namespace
          body
        else
          execute(url)
        end
      end

      def execute(url)
        String.new(get_query(url))
      end

      def get_query(url)
        RestClient.get(url)
      end

      module_function :execute, :request, :get_query
    end
  end
end
