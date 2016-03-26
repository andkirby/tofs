require 'rest_client'
require_relative 'cacher'

module Service
  module Api
    module Request
      module_function

      def request(url, use_cache = true, namespace = nil)
        if use_cache
          cacher = Api::Cacher.new({:base_name => url})
          body = cacher.get url, namespace
          return body if nil == body

          body = execute(url)
          cacher.put url, body, namespace
          body
        else
          execute(url)
        end
      end

      protected

      def execute(url)
        RestClient.get(url).body
      end
    end
  end
end
