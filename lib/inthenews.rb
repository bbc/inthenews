require 'rest_client'
require 'nokogiri'

module InTheNews
  class Item
    def initialize(element)
      @element = element
    end

    def text
      @element.inner_text
    end

    # Rescursively search for all a elements in this element and
    # return their value (removing /wiki/)
    def topics
      @element.xpath('.//a').map do |a|
        a.attr('href').gsub('/wiki/','')
      end
    end
  end

  class Parser
    def initialize
    end

    def items
      elements = doc.xpath("//div[@id='mp-itn']/ul/li")
      elements.map {|e| Item.new(e)}
    end

    def doc
      Nokogiri::HTML(content)
    end

    def wikipedia_url
      "http://en.wikipedia.org/wiki/Main_Page"
    end

    def content
      RestClient.proxy = ENV['http_proxy']
      @content ||= RestClient.get wikipedia_url
    end
  end
end
