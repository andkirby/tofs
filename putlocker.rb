#!/usr/bin/env ruby

require 'rubygems'
require 'commander'
require_relative 'lib/shell/output'
require_relative 'lib/service/put_locker/cli/put_locker_api'

module Service
  module PutLocker
    module Cli
      class PutLockerCli
        @output = nil

        include Commander::Methods

        ##
        # Get CLI API module
        #
        # @return [Service::PutLocker::Cli::PutLockerApi]
        #
        def get_api
          Service::PutLocker::Cli::PutLockerApi
        end

        ##
        # Get CLI API module
        #
        # @return [Service::PutLocker::Cli::PutLockerApi]
        #
        def get_output
          @output = Shell::Output unless @output

          @output
        end

        def run
          program :name, 'putlocker'
          program :version, '0.1.0'
          program :description, 'Movie Watcher for putlocker.is service.'

          command :urls do |c|
            c.syntax      = 'putlocker urls'
            c.summary     = ''
            c.description = 'Show URLs watch list.'
            c.action do |args, options|
              get_api::get_urls.each { |url| get_output.simple url }
            end
          end

          command :url do |c|
            c.syntax      = 'putlocker url URL'
            c.summary     = ''
            c.description = 'Show serial information by URL.'
            c.action do |args, options|
              info = get_api::get_info args.first
              get_output.simple 'Title: '.yellow + info[:label]
              get_output.simple 'URL:   '.yellow + info[:url]
            end
          end

          run!
        end
      end

      PutLockerCli.new.run if $0 == __FILE__
    end
  end
end

