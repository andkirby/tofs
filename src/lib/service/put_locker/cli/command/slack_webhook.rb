require_relative '../command'
require_relative 'command_abstract'

module Service::PutLocker::Cli::Command
  class SlackWebhook < CommandAbstract
    ##
    # Execute command
    #
    # Set/get Slack webhook URL
    #
    def execute(args, options)
      if args.empty?
        # show current URL
        url = api::slack_webhook_url
        get_output.simple url.to_s if url
      else
        api::slack_webhook_url = args.first
      end
    end

    ##
    # Initialize command
    #
    # @param [Commander::Command] command
    #
    def init_command(command)
      command.syntax      = 'putlocker slack webhook [URL]'
      command.summary     = 'Set/get Slack webhook URL.'
      command.description = 'Set/get Slack webhook URL. To read configuration run command w/o value (URL).'
    end
  end
end
