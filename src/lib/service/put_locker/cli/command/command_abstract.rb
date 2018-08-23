require 'rubygems'
require 'commander'

require_relative '../../../../shell/output'
require_relative '../command_api'

module Service
  module PutLocker
    module Cli
      module Command
        class CommandAbstract
          ##
          # Execute command
          #
          def execute(args, options)
            raise 'The method "' + __method__.to_s + '" is implemented.'
          end

          ##
          # Initialize command
          #
          # @param [Commander::Command] command
          #
          def init_command(command)
            # Example of code
            # command.syntax      = 'putlocker urls'
            # command.summary     = ''
            # command.description = 'Show URLs watch list.'
            raise 'The method "' + __method__.to_s + '" is implemented.'
          end

          ##
          # Get CLI API module
          #
          # @return [Service::PutLocker::Cli::CommandApi]
          #
          def api
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
        end
      end
    end
  end
end
