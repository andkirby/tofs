require_relative '../command'
require_relative 'command_abstract'
require_relative '../show_entity'

module Service
  module Cli
    module Command
      ##
      # Explain command
      #
      class Explain < CommandAbstract
        ##
        # Execute command
        #
        # Show explanation about serials
        # It shows Title, last saved episode of serial
        # If passed option --test it will request last episode from the online page
        #
        def execute(args, options)
          urls = args.empty? ? api.urls : args

          raise 'Empty URLs list.' if urls.count.zero?

          show_width = options.max_width ? nil : 100

          urls.each do |url|
            # Serial info
            serial = api.info url

            raise "Cannot fetch data by URL: #{url}." if serial.nil?

            serial[:label] = serial[:label].green
            serial[:url]   = url if serial[:url].nil?

            # Last episode info
            # fetch the latest online episode
            the_latest_episode = options.online ? api.fetch_last_episode(url) : false
            last_episode       = the_latest_episode || api.last_episode(url)
            api.fetch_new_episodes
            if last_episode
              serial[:last_episode] = 'Season ' + last_episode[:season_index].to_s +
                                      ' Episode ' + last_episode[:index].to_s
            else
              serial[:last_episode] = 'No'.light_red
            end

            show_entity serial, max_width: show_width, view: view_type(options)
          end
        end

        def view_type(options)
          if options.normal
            Service::Cli::ShowEntity::VIEW_NORMAL
          elsif options.short
            Service::Cli::ShowEntity::VIEW_SHORT
          elsif options.detailed
            Service::Cli::ShowEntity::VIEW_DETAILED
          else
            Service::Cli::ShowEntity::VIEW_NORMAL
          end
        end

        ##
        # Show entity data
        def show_entity(*args)
          Service::Cli::ShowEntity.show_entity *args
        end

        ##
        # Initialize command
        #
        # @param [Commander::Command] command
        #
        def init_command(command)
          command.syntax      = '[service_name] explain [URL, URL2, URLn]'
          command.summary     = 'Show serial information.'
          command.description = 'Show serial information by URL. ' \
                            'It will show information about all URLs from "watch list".'
          command.option '--online', 'Try to fetch new last episode.'
          command.option '--max-width', 'Use max width in terminal tables.'
          command.option '--detailed', 'Use "detailed" view.'
          command.option '--short', 'Use "short" view.'
          command.option '--normal', 'Use "normal" view.'
        end
      end
    end
  end
end
