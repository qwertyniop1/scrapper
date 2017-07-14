require 'curb'
require 'nokogiri'

require 'byebug'

class HTMLDocumentError < StandardError
  def initialize(message = '')
    super
  end
end

class HTMLDocument
  def initialize(html)
    @content = Nokogiri::HTML(html)
    @query = ''
  end

  def query(selector)
    @query += selector
    self
  end

  def all
    query '//'
  end

  def children
    query '/'
  end

  def tag(tag_name)
    query tag_name.to_s
  end

  def attribute(attribute, value)
    query "[contains(concat(' ', @#{attribute}, ' '), ' #{value} ')]"
  end

  def class_name(class_name)
    attribute(:class, class_name)
    self
  end

  def first
    query '[1]'
  end

  def last
    query '[last()]'
  end

  def select
    matched = @content.xpath(@query)
    @query = ''
    matched
  end

  def get
    matched = select
    raise HTMLDocumentError if matched.empty?
    matched.first
  end

  def verbose
    @query
  end
end

def get_html(url)
  http = Curl.get(url)
  http.body_str
end

class Scrapper
  def initialize(url, page_class = nil, options = {})
    @url = url
    @page_class = page_class || Page
    @pagination_parameter = options[:pagination_parameter] || 'p'
  end

  def parse
    start_page = @page_class.new(@url)

    pages = Array.new(start_page.parse.pages_count) do |index|
      @page_class.new("#{@url.chomp('/')}/?#{@pagination_parameter}=#{index + 1}")
    end

    payload = pages.drop(1).map { |page| page.parse.payload }

    ([start_page.payload] + payload).flatten
  end
end

class Page
  attr_reader :payload

  def initialize(url, options = {})
    @url = url
    @document = nil
    @payload = nil
  end

  def parse
    html = get_html(@url)
    @document = HTMLDocument.new(html)

    @payload = yield

    self
  end

  def to_s
    "#<#{self.class} @url='#{@url}'>"
  end
end

class ListPage < Page
  def initialize(url, options = {})
    super
  end

  def parse
    super do
      items = item_link_element.map { |link| link[:href] }
    end
  end

  def pages_count(count = 0)
    if block_given?
      yield(@document).text.to_i
    else
      count
    end
  end

  def item_link_element
    raise AttributeError 'No block given' unless block_given?
    yield @document
  end
end

class PetsonicListPage < ListPage
  def initialize(url, options = {})
    super
    @pagination_class = options[:pagination_class] || 'pagination'
    @item_class = options[:item_class] || 'product-block'
    @item_link_class = options[:product_img_link] || 'product_img_link'
  end

  def pages_count
    super do |document|
      document
        .all
        .tag(:ul)
        .class_name(@pagination_class)
        .first.children
        .tag(:li)
        .query('[not(@*)]')
        .last
        .children
        .tag(:a)
        .children
        .tag(:span)
        .get
    end
  end

  def item_link_element
    super do |document|
      document
        .all
        .tag(:div)
        .class_name(@item_class)
        .all
        .tag(:a)
        .class_name(@item_link_class)
        .select
    end
  end
end

def main
  target_url = ARGV.first

  scrapper = Scrapper.new(target_url, PetsonicListPage)

  p scrapper.parse
end

main
