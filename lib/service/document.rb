require 'rest_client'
require 'nokogiri'
require 'colorize'

module Service
  module Document
    def fetch(url)
      create(self::request(url))
    end

    def create(html)
      Nokogiri::HTML(html)
    end

    def request(url, verbose = false, exit_on_error = true)
      begin
        if verbose
          # TODO add output module
          output.inline url
          output.temp '...FETCHING'.yellow
        end
        result = Service::Api::Request::request url
        if verbose
          output.temp '...OK'.green
          output.inline url
        end
        result
      rescue => e
        if verbose
          output.simple "URL #{url} not found."
          exit 404 if exit_on_error
        end
        raise e
      end
    end

    module_function :request, :fetch, :create
  end
end
