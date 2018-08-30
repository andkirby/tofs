require_relative '../command'
require_relative 'command_abstract'

module Service
  module Cli
    module Command
      class Send < CommandAbstract
        ##
        # Execute command
        #
        # Send updates to Slack
        #
        def execute(_args, _options)
          message = api.send_update

          if message
            output.simple message.yellow
          else
            output.simple 'No updates yet.'.red
          end
        end

        ##
        # Initialize command
        #
        # @param [Commander::Command] command
        #
        def init_command(command)
          command.syntax      = 'putlocker send'
          command.summary     = 'Send newest episodes.'
          command.description = 'Send newest episodes to Slack (Webhook URL should be defined.'
          command.option '--online', 'Try to fetch new last episode from the online page.'
        end
      end
    end
  end
end
