#!/usr/bin/env ruby

require 'rubygems'
require 'commander'
require_relative 'lib/shell/output'
require_relative 'lib/service/put_locker/cli/command_api'

module Service
  module PutLocker
    module Cli
      class PutLockerCli
        @output = nil

        include Commander::Methods

        ##
        # Get CLI API module
        #
        # @return [Service::PutLocker::Cli::CommandApi]
        #
        def get_api
          Service::PutLocker::Cli::CommandApi
        end

        ##
        # Get CLI API module
        #
        # @return [Service::PutLocker::Cli::CommandApi]
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
            c.option '--test', 'Try to fetch new last episode.'
            c.action do |args, options|
              urls = args.empty? ? get_api::get_urls : args

              urls.each do |url|

                # Serial info
                serial = get_api::get_info url
                get_output.simple 'Title:         '.yellow + serial[:label].green
                get_output.simple 'URL:           '.yellow + serial[:url]

                # Last episode info
                # fetch the latest online episode
                the_latest_episode = options.test ? get_api::fetch_last_episode(url) : false
                last_episode = the_latest_episode || get_api::get_last_episode(url)
                if last_episode
                  label = the_latest_episode ? 'Last episode (UPD):'.red : 'Last episode:  '.yellow

                  get_output.simple label +
                                      'Season ' + last_episode[:season_index].to_s +
                                      ' Episode ' + last_episode[:index].to_s
                else
                  get_output.simple 'Last episode:  '.yellow + 'No'.light_red
                end
              end
            end
          end

          command :send do |c|
            c.syntax      = 'putlocker send'
            c.summary     = ''
            c.description = 'Send update about newest episodes.'
            c.action do |args, options|
              message = get_api::send_news_message

              if message
                get_output.simple message.yellow
              else
                get_output.simple 'No updates yet.'.red
              end
            end
          end

          command :'slack webhook' do |c|
            c.syntax      = 'putlocker slack webhook [URL]'
            c.summary     = ''
            c.description = 'Set/get Slack webhook URL.'
            c.action do |args, options|

              if args.empty?
                # show current URL
                url = get_api::get_slack_webhook_url
                get_output.simple url.to_s if url
              else
                get_api::set_slack_webhook_url args.first
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

