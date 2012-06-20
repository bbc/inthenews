require_relative '../lib/inthenews'
require 'minitest/autorun'
require 'webmock/minitest'

require 'webmock'

class TestInTheNews < MiniTest::Unit::TestCase
  def fixture_file
    fn = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'main_page_20120620.html'))
    File.open(fn, "rb").read
  end

  def setup
    @news = InTheNews::Parser.new
    stub_request(:get, "en.wikipedia.org/wiki/Main_Page").
      to_return({:body => fixture_file})

  end

  def test_returns_correct_number_of_items
    assert_equal 6, @news.items.size
  end

  def test_returns_text_of_news_headline
    assert_equal "The Supreme Court of Pakistan retroactively discharges Yousaf Raza Gillani from the prime ministership due to his contempt of court conviction.", @news.items[0].text
  end

  def test_strips_boiler_plate_from_last_item
    text = @news.items.last.text
    refute text.include?("Wikinews"), "Did not expect '#{text}' to include 'Wikinews'"
  end

  def test_returns_topics_contained_in_news_headline
    item = @news.items[0]
    assert item.topics.include? 'Supreme_Court_of_Pakistan'
    assert item.topics.include? 'Yousaf_Raza_Gillani'
    assert item.topics.include? 'Prime_Minister_of_Pakistan'
    assert item.topics.include? 'Contempt_of_court'
  end
end
