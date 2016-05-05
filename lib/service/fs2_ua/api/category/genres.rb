require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../shell/output'
require_relative '../../../api/request'
require_relative '../../../fs2_ua/api/cached'
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

          include Service::Fs2Ua::Api::Cached

          @cacher = nil
          @strict = true

          def initialize
            @strict = true
          end

          def fetch
            # read cache
            genres = get_cacher.get 'genres', 'genres'
            return filter_by_strict(genres) if nil != genres

            # grab genres
            menu   = Service::Fs2Ua::Api::Category::Menu.new.fetch
            genres = fetch_by_menu(menu)

            # write cache
            get_cacher.put('genres', genres, 'genres')

            filter_by_strict(genres)
          end

          def filter_by_strict(genres)
            if @strict
              genres.each { |key, list|
                list.delete_if{|i|
                  get_ignored_names.include?(i[:label])
                  # puts i[:label]
                }
              }
            end
            genres
          end

          def fetch_by_menu(menu)
            genres = {}
            menu.each { |top_node|
              unless top_node[:_children]
                raise 'No children.'
              end

              top_node[:_children].each { |node|
                result = fetch_by_url(node[:url])
                next if result == nil
                genres[node[:url]] = result
              }
            }
            genres
          end

          def fetch_by_url(url)
            genres_page = fetch_url_to_genres_page(url)
            return nil unless genres_page[:url]

            ##
            # Fetch genres list
            #
            fetch_genres(genres_page)
          end

          def fetch_genres(result)
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

          protected

          def fetch_url_to_genres_page(url)
            html = Service::Document::fetch(
              Service::Fs2Ua::get_base_url + url
            )
            return nil if html == nil

            # Fetch genre URL
            fetcher = HtmlReader::Page::EntityFetcher.new
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

          def get_cache_default_namespace
            'genres'
          end

          def get_ignored_names
            [
              "\xD0\xAD\xD1\x80\xD0\xBE\xD1\x82\xD0\xB8\xD0\xBA\xD0\xB0"
            ]
          end
        end
      end
    end
  end
end
