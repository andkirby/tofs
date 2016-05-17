require 'rubygems'
require 'commander'

require_relative '../../../shell/output'
require_relative 'command_api'
require_relative 'command/urls'
require_relative 'command/explain'

module Service
  module PutLocker
    module Cli
      class CommandPoint
        @output = nil

        include Commander::Methods

        def run
          program :name, 'putlocker'
          program :version, '0.1.0'
          program :description, 'Movie Watcher for putlocker.is service.'

          command :urls do |c|
            prepare c, Cli::Command::Urls.new
          end

          command :explain do |c|
            prepare c, Cli::Command::Explain.new
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

        protected

        ##
        # Prepare command for running
        #
        # @param [Commander::Command] command
        # @param [Service::PutLocker::Cli::Command::CommandAbstract] executor
        #
        def prepare(command, executor)
          executor.init_command command
          command.action do |args, options|
            executor.execute(args, options)
          end
        end
      end
    end
  end
end
