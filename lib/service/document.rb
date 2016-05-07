require 'nokogiri'
require 'colorize'
require_relative '../shell/output'
require_relative 'api/request'

module Service
  module Document
    def fetch(url, verbose = false, exit_on_error = false)
      create(self::request(url, verbose, exit_on_error))
    end

    def create(html)
      Nokogiri::HTML(html)
    end

    def request(url, verbose = false, exit_on_error = false)
      begin
        if verbose
          # TODO add output module
          Shell::Output.inline url
          Shell::Output.temp '...FETCHING'.yellow
        end
        result = Service::Api::Request::request url
        if verbose
          Shell::Output.temp '...OK'.green
          Shell::Output.inline url
        end
        result
      rescue => e
        if verbose
          Shell::Output.simple "URL #{url} not found."
          exit 404 if exit_on_error
        end
        raise e
      end
    end

    module_function :request, :fetch, :create
  end
end
