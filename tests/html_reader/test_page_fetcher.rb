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

    protected

    ##
    # Get HTML content
    #
    # @return [String]

    def get_content
      return @content if nil != @content

      @content = File.open(__dir__ + '/_fixture/page_fetcher.html').read
    end
  end
end
