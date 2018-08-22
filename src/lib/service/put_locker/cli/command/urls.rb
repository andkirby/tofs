require_relative '../command'
require_relative 'command_abstract'

module Service::PutLocker::Cli::Command
  class Urls < CommandAbstract
    ##
    # Execute command
    #
    def execute(args, options)
      if args
        get_api::add_urls args
      else
        get_api::get_urls.each { |url| get_output.simple url }
      end
    end

    ##
    # Initialize command
    #
    # @param [Commander::Command] command
    #
    def init_command(command)
      command.syntax      = 'putlocker urls [URL1, URL2, .. URLn]'
      command.summary     = 'Add/show watch URLs list.'
      command.description = 'Show URLs watch list. New URLs will be added if passed as arguments.'
    end
  end
end
