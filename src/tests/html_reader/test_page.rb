require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require 'pp'
require_relative '../../lib/html_reader/page_fetcher'

module HtmlReader
  class TestPage < Test::Unit::TestCase

    # Test fetching nodes on a page
    def test_following_sibling
      document = Nokogiri::HTML(get_html)

      block = Page::fetch_node(document, {:css => '#block'})
      nodes = Page::fetch_nodes(block, {:xpath => 'a/following-sibling::ul/li'})

      assert_equal(2, nodes.count)
    end

    protected

    def get_html
      <<-'HTML'
<li id="block">
  <a>base</a>
  <ul>
    <li><a>node #1</a></li>
    <li><a>node #2</a></li>
  </ul>
<li>
      HTML
    end
  end
end
