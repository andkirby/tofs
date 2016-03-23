require 'test/unit'
require 'mocha/test_unit'
require 'nokogiri'
require_relative '../../../lib/reader/page/entity'

module Reader
  module Page
    class TestEntity < Test::Unit::TestCase
      # Test get/set instructions
      def test_set_instructions
        obj   = Entity.new
        value = {:aa => 'aa'}
        assert_instance_of(Entity, obj.set_instructions(value))
        assert_equal(value, obj.get_instructions)
      end

      # Test fetching label text
      def test_fetch_text
        html = Nokogiri::HTML(get_content)
        obj  = Entity.new
        obj.set_instructions(
          {
            :name1 => {
              :type     => :value,
              :selector => '.test-block a.deep-in',
            }
          })
        assert_equal ({:name1 => 'Link label 1'}), obj.fetch(html)
      end

      # Test fetching non-stripped value
      def test_fetch_non_stripped_text
        html = Nokogiri::HTML(get_content)
        obj  = Entity.new
        obj.set_instructions(
          {
            :name1 => {
              :type     => :value,
              :filter   => :no_strip,
              :selector => '.test-block a.deep-in',
            }
          })
        assert_equal "\n    \n      Link label 1\n    \n  ", obj.fetch(html)[:name1]
      end

      # Test fetching Nokogiri::XML::Element instead text
      def test_fetch_element
        html = Nokogiri::HTML(get_content)
        obj  = Entity.new
        obj.set_instructions(
          {
            :name1 => {
              :type     => :value,
              :filter   => :element,
              :selector => '.test-block a.deep-in',
            }
          })
        assert_instance_of Nokogiri::XML::Element, obj.fetch(html)[:name1]
      end

      # Test fetching html text of found node
      def test_fetch_node_text
        html = Nokogiri::HTML(get_content)
        obj  = Entity.new
        obj.set_instructions(
          {
            :name1 => {
              :type     => :value,
              :filter   => :node_text,
              :selector => '.test-block a.deep-in',
            }
          })
        expected = <<-html
<a class="deep-in" href="/test/path/main">
    <span>
      Link label 1
    </span>
  </a>
        html
        assert_equal expected.strip, obj.fetch(html)[:name1]
      end

      # Test fetching value of duplicated node
      def test_fetch_node_duplicate
        html = Nokogiri::HTML(get_content)
        obj  = Entity.new
        obj.set_instructions(
          {
            :name1 => {
              :type     => :value,
              :selector => '.double-block a.duplicate',
            }
          })
        assert_equal 'Link label 22 first', obj.fetch(html)[:name1]
      end

      # Test fetching value from with function
      def test_fetch_func_node
        html = Nokogiri::HTML(get_content)
        obj  = Entity.new
        obj.set_instructions(
          {
            :vote_up   => {
              :type     => :value,
              :selector => '.vote-up',
            },
            :vote_down => {
              :type     => :value,
              :selector => '.vote-down',
            },
            :vote_diff => {
              :type     => :function,
              :function => Proc.new { |info, name, document, instruction|
                info[:vote_up].to_i - info[:vote_down].to_i
              },
            }
          })
        data = obj.fetch(html)
        assert_equal '10', data[:vote_up]
        assert_equal '3', data[:vote_down]
        assert_equal 7, data[:vote_diff]
      end

      protected

      def get_content
        <<-html
<div class="test-block">
  <a class="deep-in" href="/test/path/main">
    <span>
      Link label 1
    </span>
  </a>
  <div class="double-block">
    <a class="first-link duplicate" href="/test/path">
      <span>
        Link label 22 first
      </span>
    </a>
    <a class="second-link duplicate" href="/test/another-path">
      <span>
        Link label 22 second
      </span>
    </a>
    <span class="vote-up">10</span>
    <span class="vote-down">3</span>
  </div>
</div>
        html
      end
    end
  end
end
