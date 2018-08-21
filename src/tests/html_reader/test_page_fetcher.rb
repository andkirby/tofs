require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require 'pp'
require_relative '../../lib/html_reader/page_fetcher'

module HtmlReader
  class TestPageFetcher < Test::Unit::TestCase
    # Test get/set instructions
    def test_set_instructions
      obj   = PageFetcher.new
      value = {:aa => 'aa'}
      assert_instance_of(PageFetcher, obj.set_instructions(value))
      assert_equal(value, obj.get_instructions)
    end

    # Test fetching nodes on a page
    def _test_fetch_nodes
      obj  = PageFetcher.new
      html = Nokogiri::HTML(get_content)
      obj.set_instructions(
        {
          :entity => {
            :type         => :selector,
            :selector     => '.blocks .nodes',
            # Instructions for entity which will be use in EntityFetcher
            :instructions => [
              {
                :selector => 'span.item-text',
                :data     => {:my_item => {}}
              }
            ],
          },
        })
      # todo mock using EntityFetcher class
      assert_equal(
        [{:my_item => 'b2'}, {:my_item => 'b1'},
         {:my_item => 'a2'}, {:my_item => 'a1'}],
        obj.fetch(html))
    end

    # Test fetching nodes on a page
    def test_fetch_child_nodes
      obj  = PageFetcher.new
      html = Nokogiri::HTML(get_content)

      obj.set_instructions(
        {
          # block where entities can be found
          :block        => {
            :type     => :selector,
            :selector => '.main-menu > div',
          },
          :entity => [
              {
                :xpath => 'a',
                :data  => {
                  :label => {},
                  :url   => {
                    :type      => :attribute,
                    :attribute => 'href',
                  }
                }
              },
              {
                :xpath => 'a/following-sibling::div',
                :data => {
                  :_children => {
                    :type      => :children,
                    :instructions => :the_same
                  },
                },
              }
            ],
        }
      )

      # todo mock using EntityFetcher class
      # region expected
      expected = [
        {
          :label     => 'Video',
          :url       => '/video',
          :_children => [
            {
              :label     => 'Movies',
              :url       => '/video/movies',
              :_children => [
                {
                  :label => 'Action',
                  :url   => '/video/movies/action',
                },
                {
                  :label => 'Sci-Fi',
                  :url   => '/video/movies/sci-fi',
                },
              ]
            },
            {
              :label     => 'Series',
              :url       => '/video/series',
              :_children => [
                {
                  :label => 'Action',
                  :url   => '/video/series/action',
                },
                {
                  :label => 'Sci-Fi',
                  :url   => '/video/series/sci-fi',
                },
              ]
            },
            {
              :label => 'Cartoons',
              :url   => '/video/cartoons',
            },
          ]
        },
        {
          :label     => 'Books',
          :url       => '/books',
          :_children => [
            {
              :label => 'Documentary',
              :url   => '/books/doc',
            },
            {
              :label => 'Artistic',
              :url   => '/books/artistic',
            },
          ]
        },
      ]
      # endregion

      assert_equal(expected, obj.fetch(html))
    end

    # Test fetching nodes ul-li
    def test_fetch_ul_li
      # TODO fix the instructions or bugs
      # raise 'not implemented yet.'

      obj  = PageFetcher.new
      html = Nokogiri::HTML(get_content(file: 'page_fetcher_ul_li.html'))

      obj.set_instructions(
          {
              # block where entities can be found
              :block        => {
                  :type     => :selector,
                  :selector => '#menu/li',
              },
              :entity => [
                  {
                      :xpath => 'a',
                      :data  => {
                          :label => {},
                          :url   => {
                              :type      => :attribute,
                              :attribute => 'href',
                          }
                      }
                  },
                  {
                      :xpath => 'a/following-sibling::ul/li',
                      :data => {
                          :_children => {
                              :type      => :children,
                              :instructions => :the_same
                          },
                      },
                  }
              ],
          }
      )

      # todo mock using EntityFetcher class
      # region expected
      expected = [
          {
              :label     => 'home',
              :url       => '',
          },
          {
              :label     => 'Genre',
              :url       => '',
              :_children => [
                  {
                      :label => 'Action movies',
                      :url   => '/country/action',
                  },
                  {
                      :label => 'Adventure movies',
                      :url   => '/country/adventure'
                  },
                  {
                      :label => 'Animation movies',
                      :url   => '/country/animation'
                  }
              ]
          }
      ]
      # endregion

      result = obj.fetch(html)
      assert_equal(expected, result)
    end

    def test_last_page
      obj  = PageFetcher.new
      html = Nokogiri::HTML(get_content)
      obj.set_instructions(
        {
          :last_page => {
            :selector => '.pager > span.active:last',
          }
        })
      assert_true(obj.last_page?(html))
    end

    def test_two_children
      obj  = PageFetcher.new
      html = Nokogiri::HTML(<<-HTML
<ul>
  <li>
    <a href="/home">Home</a>
  </li>
  <li>
    <a href="/plenty">Plenty</a>
    <ul>
      <li>
        <a href="/plenty/one">Plenty One</a>
      </li>
      <li>
        <a href="/plenty/two">Plenty Two</a>
      </li>
    </ul>
  </li>
</ul>
HTML
)
      obj.set_instructions(
          {
              # block where entities can be found
              :block        => {
                  :type     => :selector,
                  :selector => 'ul/li',
              },
              :entity => [
                  # data element instructions
                  {
                      :xpath => 'a',
                      :data  => {
                          :label => {},
                          :url   => {
                              :type      => :attribute,
                              :attribute => 'href',
                          }
                      }
                  },
                  # children instructions
                  # each found element will be process by data element instructions
                  # because :instructions => :the_same
                  {
                      :xpath => 'a/following-sibling::ul/li',
                      :data => {
                          :_children => {
                              :type      => :children,
                              :instructions => :the_same
                          },
                      },
                  }
              ],
          }
      )
      # region expected
      expected = [
          {
              :label     => 'Home',
              :url       => '/home',
          },
          {
              :label     => 'Plenty',
              :url       => '/plenty',
              :_children => [
                  {
                      :label => 'Plenty One',
                      :url   => '/plenty/one',
                  },
                  {
                      :label => 'Plenty Two',
                      :url   => '/plenty/two'
                  },
                  {
                      :label => 'Animation movies',
                      :url   => '/country/animation'
                  }
              ]
          }
      ]
      # endregion
      assert_equal(expected, obj.fetch(html))
    end

    protected

    ##
    # Get HTML content
    #
    # @return [String]

    def get_content(file: 'page_fetcher.html')
      return @content if nil != @content

      @content = File.open(__dir__ + '/_fixture/'+file).read
    end
  end
end
