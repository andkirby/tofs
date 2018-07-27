require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../api/request'
require_relative '../../../document'
require_relative '../../../fs2_ua'
require_relative '../../../fs2_ua/api/cached'
require_relative 'menu'
# TODO Refactor to abstract filter type class
module Service
  module Fs2Ua
    module Api
      module Category
        class Years
          YEAR_LABEL = "\xD0\xBF\xD0\xBE\x20\xD0\xB3\xD0\xBE\xD0\xB4\xD0\xB0\xD0\xBC"

          include Service::Fs2Ua::Api::Cached

          @cacher = nil

          def fetch
            # read cache
            years = get_cacher.get 'years', 'years'
            return years if nil != years

            # grab years
            menu  = Service::Fs2Ua::Api::Category::Menu.new.fetch
            years = fetch_by_menu(menu)
            years = years.each { |i, group|
              group.each { |node|
                # convert 90 to 1990
                node[:label] = '19' + node[:label] if node[:label].length == 2
                # convert "30s and earlier"
                node[:label] = '19' + node[:label] if node[:label] ==
                  "\x33\x30\x2D\xD0\xB5\x20\xD0\xB8\x20\xD1\x80\xD0\xB0\xD0\xBD\xD0\xB5\xD0\xB5"
              }
              years[i] = group.sort_by! { |node| node[:label] }.reverse
            }
            # write cache
            get_cacher.put('years', years, 'years')

            years
          end

          def fetch_by_menu(menu)
            years = {}
            menu.each { |top_node|
              unless top_node[:_children]
                raise 'No children.'
              end

              top_node[:_children].each { |node|
                result = fetch_by_url(node[:url])
                next if result == nil
                years[node[:url]] = result
              }
            }
            years
          end

          def fetch_by_url(url)
            years_page = fetch_url_to_years_page(url)
            return nil unless years_page[:url]

            ##
            # Fetch years list
            #
            fetch_years(years_page)
          end

          def fetch_years(result)
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

          def fetch_url_to_years_page(url)
            html = Service::Document::fetch(
              Service::Fs2Ua::get_base_url + url
            )
            return nil if html == nil

            # Fetch genre URL
            fetcher = HtmlReader::Page::EntityFetcher.new
            fetcher.set_instructions(
              [
                {
                  :selector => "a:contains('" + YEAR_LABEL + "')",
                  :data     => {
                    :url => {:type => :attribute, :attribute => 'href'},
                  },
                }]
            )

            fetcher.fetch(html)
          end

          def get_cache_default_namespace
            'years'
          end
        end
      end
    end
  end
end
