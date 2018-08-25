require_relative '../../../html_reader/page_fetcher'
require_relative '../../../html_reader/page/entity_fetcher'
require_relative '../../../service/document'
require_relative '../../../service/put_locker'
require_relative '../../../service/put_locker/api/cached'
require_relative 'serial/episodes'

module Service
  module PutLocker
    module Api
      module Movie
        module_function

        # Include caching methods
        include Service::PutLocker::Api::Cached

        ##
        # Fetch movie info
        #
        # @param [String] url   Base season page URL
        # @return [Hash]

        def fetch_info(url, episodes: false)
          info = cacher.get 'info-' + url + episodes.to_s
          return info if nil != info

          fetcher = HtmlReader::PageFetcher.new
          # TODO add fetching genres
          fetcher.instructions = {
              :block  => {
                  :selector => 'body'
              },
              :entity => [
                  {
                      :selector => '.topdescriptiondesc h2',
                      :data     => {
                          :label => {},
                      }
                  },
                  {
                      :selector => '.topdescriptionthumb img',
                      :data     => {
                          :thumbnail => {
                              type:      :attribute,
                              attribute: 'src',
                          },
                      }
                  },
                  {
                      :selector => '.episodelistss .movies-letter',
                      :data     => {
                          :seasons => {
                              :type         => :children,
                              :instructions => {
                                  :selector => 'a',
                                  :data     => {
                                      :label => {},
                                      :url   => {
                                          :type      => :attribute,
                                          :attribute => 'href',
                                      },
                                  }
                              }
                          },
                      }
                  },
                  {
                      :data => {
                          :serial => {
                              :type     => :function,
                              :function => Proc.new {|name, instruction, data, options|
                                !data[:seasons].empty?
                              },
                          },
                      }
                  },
                  {
                      :selector => ".topdescriptiondesc li:has(strong:contains('Genre'))",
                      :data     => {
                          :genre => {
                              :type         => :children,
                              :instructions => {
                                  :selector => 'a',
                                  :data     => {
                                      :label => {},
                                      :url   => {
                                          :type      => :attribute,
                                          :attribute => 'href',
                                      },
                                  }
                              }
                          },
                      }
                  },
                  {
                      :selector => ".topdescriptiondesc li:has(strong:contains('Actor'))",
                      :data     => {
                          :actor => {
                              :type         => :children,
                              :instructions => {
                                  :selector => 'a',
                                  :data     => {
                                      :label => {},
                                      :url   => {
                                          :type      => :attribute,
                                          :attribute => 'href',
                                      },
                                  }
                              }
                          },
                      }
                  },
                  {
                      :selector => ".topdescriptiondesc li:has(strong:contains('Director'))",
                      :data     => {
                          :director => {
                              :type         => :children,
                              :instructions => {
                                  :selector => 'a',
                                  :data     => {
                                      :label => {},
                                      :url   => {
                                          :type      => :attribute,
                                          :attribute => 'href',
                                      },
                                  }
                              }
                          },
                      }
                  },
                  {
                      :selector => ".topdescriptiondesc li:has(strong:contains('Country'))",
                      :data     => {
                          :country => {
                              :type         => :children,
                              :instructions => {
                                  :selector => 'a',
                                  :data     => {
                                      :label => {},
                                      :url   => {
                                          :type      => :attribute,
                                          :attribute => 'href',
                                      },
                                  }
                              }
                          },
                      }
                  },
                  {
                      :selector => ".topdescriptiondesc li:has(strong:contains('Duration')) span",
                      :data     => {
                          :duration => {},
                      }
                  },
                  {
                      :selector => ".topdescriptiondesc li:has(strong:contains('IMDb')) span",
                      :data     => {
                          :imdb => {},
                      }
                  },
                  {
                      :selector => '.topdescriptiondesc p',
                      :data     => {
                          :description => {},
                      }
                  },
              ]
          }

          info = fetcher.fetch(get_document(url))

          if episodes
            info.each do |el|
              if !el[:seasons].empty?
                el[:seasons].each do |season|
                  season[:episodes] = Service::PutLocker::Api::Serial::Episodes::fetch(season[:url])
                end
              end
            end
          end


          return nil unless info

          info = info.first
          cacher.put 'info-' + url + episodes.to_s, info

          info
        end

        protected

        module_function

        def get_document(url)
          Service::Document::fetch(url)
        end

        def get_cache_options
          {:timeout => 3600 * 24 * 365}
        end

        ##
        # Get default namespace
        #
        # @return [String]

        def get_cache_default_namespace
          'movie'
        end

        # Declare included module functions
        module_function :cacher, :get_cache_basename
      end
    end
  end
end
