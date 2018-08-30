require_relative '../command'
require_relative 'command_abstract'

module Service
  module Cli
    module Command
      class Urls < CommandAbstract
        ##
        # Execute command
        #
        def execute(args, _options)
          if args.count > 0
            api.add_urls args
          else
            api.urls.each { |url| output.simple url }
          end
        end

        ##
        # Initialize command
        #
        # @param [Commander::Command] command
        #
        def init_command(command)
          command.syntax      = '[service_name] urls [URL1, URL2, .. URLn]'
          command.summary     = 'Add/show watch URLs list.'
          command.description = 'Show URLs watch list. New URLs will be added if passed as arguments.'
        end
      end
    end
  end
end
