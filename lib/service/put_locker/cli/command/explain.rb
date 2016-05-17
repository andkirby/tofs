require_relative '../command'
require_relative 'command_abstract'

module Service::PutLocker::Cli::Command
  class Explain < CommandAbstract
    ##
    # Execute command
    #
    # Show explanation about serials
    # It shows Title, last saved episode of serial
    # If passed option --test it will request last episode from the online page
    #
    def execute(args, options)
      urls = args.empty? ? get_api::get_urls : args

      urls.each do |url|

        # Serial info
        serial = get_api::get_info url
        get_output.simple 'Title:         '.yellow + serial[:label].green
        get_output.simple 'URL:           '.yellow + serial[:url]

        # Last episode info
        # fetch the latest online episode
        the_latest_episode = options.online ? get_api::fetch_last_episode(url) : false
        last_episode = the_latest_episode || get_api::get_last_episode(url)
        if last_episode
          label = the_latest_episode ? 'Last episode (UPD):'.red : 'Last episode:  '.yellow

          get_output.simple label +
                              'Season ' + last_episode[:season_index].to_s +
                              ' Episode ' + last_episode[:index].to_s
        else
          get_output.simple 'Last episode:  '.yellow + 'No'.light_red
        end
      end
    end

    ##
    # Initialize command
    #
    # @param [Commander::Command] command
    #
    def init_command(command)
      command.syntax      = 'putlocker explain [URL, URL2, URLn]'
      command.summary     = 'Show serial information.'
      command.description = 'Show serial information by URL. ' +
        'With omitted URL it will show information about all URLs from "watch list".'
      command.option '--online', 'Try to fetch new last episode.'
    end
  end
end
