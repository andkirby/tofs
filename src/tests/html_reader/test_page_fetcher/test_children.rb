require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require 'pp'
require_relative '../../../lib/html_reader/page_fetcher'

PageFetcher = HtmlReader::PageFetcher

module HtmlReader::TestPageFetcher
    class TestChildren < Test::Unit::TestCase
      def test_two_children
        obj  = PageFetcher.new
        html = Nokogiri::HTML(<<-HTML
  <ul>
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
    <li>
      <a href="/home">Home</a>
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
                        :data => {
                            :label => {},
                            :url => {
                                :type => :attribute,
                                :attribute => 'href',
                            }
                        }
                    },
                    # children instructions
                    # each found element will be process by data element instructions
                    # because :instructions => :the_same
                    {
                        :xpath => 'a/following-sibling::ul/li',
                        :gather_data => true,
                        :data => {
                            :_children => {
                                :type => :children,
                                :instructions => :the_same,
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
