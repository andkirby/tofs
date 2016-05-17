require_relative '../command'
require_relative 'command_abstract'

module Service::PutLocker::Cli::Command
  class Urls < CommandAbstract
    ##
    # Execute command
    #
    # @return void
    #
    def execute(args, options)
      get_api::get_urls.each { |url| get_output.simple url }
    end
  end
end
