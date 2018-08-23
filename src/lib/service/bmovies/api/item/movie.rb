require_relative '../../../../html_reader/page_fetcher'
require_relative '../../../../shell/output'
require_relative '../../../api/request'
require_relative '../../../document'
require_relative '../../../bmovies'
require_relative '../../../bmovies/api/cached'
require 'uri'
require 'pp'

module Service
  module Bmovies
    module Api
      module Item
        class Movie
          include Service::Bmovies::Api::Cached

          @use_cache = false

          def fetch(uri:, use_cache: @use_cache)
            if use_cache
              items = cacher.get 'item', get_cache_default_namespace
              return items if nil != items
            end

            # fetch
            html = Service::Document::fetch(
                Service::Bmovies::get_base_url.delete_suffix('/') +
                    '/' + uri.delete_prefix('/'),
                use_cache: use_cache)

            fetcher              = HtmlReader::PageFetcher.new
            fetcher.instructions = self::menu_instructions
            items                = fetcher.fetch(html).first

            cacher.put 'items', items, get_cache_default_namespace

            items
          end

          def menu_instructions
            {
                # block where entities can be found
                :block  => {
                    :type     => :selector,
                    :selector => '#info',
                },
                :entity => [
                    {
                        :selector => 'h1',
                        :data     => {
                            :label => {},
                        }
                    },
                    {
                        :selector => ".row .meta dt:contains('Quality:') ~ dd:first span",
                        :data     => {
                            :quality => {},
                        }
                    },
                    {
                        :selector => '.thumb img',
                        :data     => {
                            :thumbnail => {
                                :type      => :attribute,
                                :attribute => 'src',
                            },
                        }
                    },
                    {
                        :selector => '.meta span:has(span.imdb) b',
                        :data     => {
                            :imdb => {},
                        }
                    },
                    {
                        :selector    => ".row .meta dt:contains('Genre:') ~ dd:first",
                        :gather_data => true,
                        :data        => {
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
                        :selector    => ".row .meta dt:contains('Stars:') ~ dd:first",
                        :gather_data => true,
                        :data        => {
                            :stars => {
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
                        :selector => ".row .meta dt:contains('Director:') ~ dd:first",
                        :data     => {
                            :director => {},
                        }
                    },
                    {
                        :selector    => ".row .meta dt:contains('Country:') ~ dd:first",
                        :gather_data => true,
                        :data        => {
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
                        :selector => ".row .meta dt:contains('Rating:') ~ dd:first > span:first",
                        :data     => {
                            :rating => {},
                        }
                    },
                    {
                        :selector => ".row .meta dt:contains('Release:') ~ dd:first",
                        :data     => {
                            :release => {},
                        }
                    },
                    {
                        :selector => '.desc',
                        :data     => {
                            :description => {},
                        }
                    },
                ],
            }
          end

          def get_cache_default_namespace
            'movie'
          end
        end
      end
    end
  end
end
