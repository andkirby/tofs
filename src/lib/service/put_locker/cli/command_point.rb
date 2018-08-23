require 'rubygems'
require 'commander'

require_relative '../../../shell/output'
require_relative 'command_api'
require_relative 'command/urls'
require_relative 'command/send'
require_relative 'command/explain'
require_relative 'command/slack_webhook'

# The main class of "putlocker" commands
module Service
  module PutLocker
    module Cli
      class CommandPoint
        @output = nil

        include Commander::Methods

        def run
          program :name, 'putlocker'
          program :version, '0.1.0'
          program :description, 'Movie Watcher for Putlocker service.'

          # region Init commands
          command :urls do |c|
            prepare_command c, Cli::Command::Urls.new
          end

          command :explain do |c|
            prepare_command c, Cli::Command::Explain.new
          end

          command :send do |c|
            prepare_command c, Cli::Command::Send.new
          end

          command :'slack webhook' do |c|
            prepare_command c, Cli::Command::SlackWebhook.new
          end
          # endregion

          run!
        end

        protected

        ##
        # Prepare command for running
        #
        # @param [Commander::Command] command
        # @param [Service::PutLocker::Cli::Command::CommandAbstract] executor
        #
        def prepare_command(command, executor)
          executor.init_command command
          command.action do |args, options|
            executor.execute(args, options)
          end
        end
      end
    end
  end
end
