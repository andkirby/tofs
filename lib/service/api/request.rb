require 'uri'
require 'rest_client'
require_relative 'cacher'

module Service
  module Api
    module Request
      def request(url, use_cache = true, namespace = nil)
        if use_cache
          cacher = Api::Cacher.new({:base_name => URI.parse(url).host})
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
        RestClient.get(url).body
      end

      module_function :execute, :request
    end
  end
end
