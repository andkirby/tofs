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

          command :explain do |c|
            c.syntax      = 'putlocker explain [URL]'
            c.summary     = ''
            c.description = 'Show serial information by URL. URL can be omitted. In this case it will show information about all URLs from "watch list".'
            c.action do |args, options|
              urls = args.empty? ? get_api::get_urls : args

              urls.each do |url|
                serial = get_api::get_info url
                get_output.simple 'Title:         '.yellow + serial[:label].green
                get_output.simple 'URL:           '.yellow + serial[:url]
                last_episode = get_api::get_last_episode url
                if last_episode
                  get_output.inline 'Last episode:  '.yellow +
                                      'Season ' + last_episode[:season_index].to_s +
                                      ' Episode ' + last_episode[:index].to_s
                else
                  get_output.inline 'Last episode:  '.yellow + 'No'.light_red
                end
              end
            end
          end

          run!
        end
      end

      PutLockerCli.new.run if $0 == __FILE__
    end
  end
end

