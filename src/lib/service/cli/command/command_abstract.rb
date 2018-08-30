require 'commander'

require_relative '../../../shell/output'
require_relative '../command_api'

module Service
  module Cli
    module Command
      ##
      # Abstract class for a command
      #
      class CommandAbstract
        attr_reader :api, :output

        def initialize(api: nil, output: nil)
          @api = api || Service::Cli::CommandApi.new
          @output = output || Shell::Output
        end

        ##
        # Execute command
        #
        def execute # (args, options)
          raise 'The method "' + __method__.to_s + '" is implemented.'
        end

        ##
        # Initialize command
        #
        def init_command # (Commander::Command command)
          # Example of code
          # command.syntax      = 'command arg_1'
          # command.summary     = 'short summary of the command'
          # command.description = 'to-do some extra information here.'
          raise 'The method "' + __method__.to_s + '" is implemented.'
        end

      end
    end
  end
end
