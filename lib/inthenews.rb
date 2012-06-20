require 'rest_client'
require 'nokogiri'

module InTheNews
  class Item
    def initialize(element)
      @element = element
      remove_noprint_elements!
    end

    # Remove any child nodes with class "nopront". This removes the
    # boilerplate Wikinews, Obituries etc.
    def remove_noprint_elements!
      @element.xpath('//*[starts-with(@class,"noprint")]').each do |node|
        node.children.remove
      end
    end

    def text
      @element.inner_text
    end

    def html
      @element.inner_html
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
