require 'rubygems'
require 'commander'

require_relative '../../../../shell/output'
require_relative '../command_api'

module Service
  module PutLocker
    module Cli
      module Command
        ##
        # Abstract class for a command
        #
        class CommandAbstract
          ##
          # Execute command
          #
          def execute #(args, options)
            raise 'The method "' + __method__.to_s + '" is implemented.'
          end

          ##
          # Initialize command
          #
          def init_command #(Commander::Command command)
            # Example of code
            # command.syntax      = 'command arg_1'
            # command.summary     = 'short summary of the command'
            # command.description = 'to-do some extra information here.'
            raise 'The method "' + __method__.to_s + '" is implemented.'
          end

          ##
          # Get CLI API module
          #
          # @return [Service::PutLocker::Cli::CommandApi]
          #
          def api
            @api ||= Service::PutLocker::Cli::CommandApi.new
          end

          ##
          # Get CLI API module
          #
          # @return [Shell::Output]
          #
          def output
            @output ||= Shell::Output
          end
        end
      end
    end
  end
end
