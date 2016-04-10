require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../shell/output'
require_relative '../../../api/request'
require_relative '../../../document'
require_relative '../../../fs2_ua'
require_relative 'menu'
require 'uri'

module Service
  module Fs2Ua
    module Api
      module Category
        class Genres
          GENRE_LABEL = "\xD0\xBF\xD0\xBE\x20\xD0\xB6\xD0\xB0\xD0\xBD\xD1\x80\xD0\xB0\xD0\xBC"

          @cacher = nil

          def fetch
            # read cache
            genres = get_cacher.get 'genres', 'genres'
            return genres if nil != genres

            # grab genres
            genres = {}
            Service::Fs2Ua::Api::Category::Menu.new.fetch.each { |top_node|
              unless top_node[:_children]
                raise 'No children.'
              end
              top_node[:_children].each { |node|
                result = fetch_url_to_genres_page(node)
                next unless result[:url]

                ##
                # Fetch genre URL
                #
                url = fetch_genre_url(result)

                next if url == nil

                genres[node[:url]] = url
              }
            }
            # write cache
            get_cacher.put('genres', genres, 'genres')

            genres
          end

          protected

          def fetch_url_to_genres_page(node)
            html = Service::Document::fetch(
              Service::Fs2Ua::get_base_url + node[:url]
            )
            return nil if html == nil

            # Fetch genre URL
            fetcher     = HtmlReader::Page::EntityFetcher.new
            fetcher.set_instructions(
              [
                {
                  :selector => "a:contains('" + GENRE_LABEL + "')",
                  :data     => {
                    :url => {:type => :attribute, :attribute => 'href'},
                  },
                }]
            )

            fetcher.fetch(html)
          end

          def fetch_genre_url(result)
            html = Service::Document::fetch(
              Service::Fs2Ua::get_base_url + result[:url].sub('//' + Fs2Ua::HOSTNAME, '')
            )

            return nil if html == nil

            fetcher = HtmlReader::PageFetcher.new
            fetcher.set_instructions(
              {
                :block  => {:selector => '.main'},
                :entity => [
                  {
                    :selector => 'a',
                    :data     => {
                      :url   => {:type => :attribute, :attribute => 'href'},
                      :label => {},
                    },
                  }]
              }
            )
            fetcher.fetch(html)
          end

          def get_cacher
            return @cacher if nil != @cacher
            Service::Api::Cacher.new(
              {
                :base_name         => Service::Fs2Ua::HOSTNAME,
                :default_namespace => 'genres',
              })
          end
        end
      end
    end
  end
end
