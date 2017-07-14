require 'curb'
require 'nokogiri'
require 'logger'

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

class NullLogger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end

class Scrapper
  def initialize(url, options = {})
    @url = url
    @page_class = options[:list_page_class] || Page
    @pagination_parameter = options[:pagination_parameter] || 'p'
    @logger = options[:logger] || NullLogger.new
    @options = options
  end

  def parse
    @logger.info "Start processing url: #{@url}"

    start_page = @page_class.new(@url, @options)

    pages_quantity = start_page.parse.respond_to?(:pages_count) ? start_page.pages_count : 0

    return [start_page.payload] unless pages_quantity > 1

    @logger.info "Found #{pages_quantity - 1} extra pages:"

    pages = Array.new(pages_quantity) do |index|
      page_url = "#{@url.chomp('/')}/?#{@pagination_parameter}=#{index + 1}"
      @logger.info "\t#{index}: #{page_url}" unless index.zero?
      @page_class.new(page_url, @options)
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
    @logger = options[:logger] || NullLogger.new
    @options = options
  end

  def parse
    @logger.info "Fetching HTML from #{@url}"

    html = get_html(@url)
    @document = HTMLDocument.new(html)

    @payload = yield if block_given?

    self
  end

  def to_s
    "#<#{self.class} @url='#{@url}'>"
  end
end

class ListPage < Page
  def initialize(url, options = {})
    super
    @page_class = options[:item_page_class] || Page
  end

  def parse
    super do
      links = item_link_element
      @logger.info "Found #{links.size} links at #{@url}:"
      urls = links.each_with_index.map do |link, index|
        url = link[:href]
        @logger.info "\t#{index + 1}: #{url}"
        url
      end
      urls.map do |url|
        @page_class.new(url, @options).parse
      end
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

class ItemPage < Page
  def initialize(url, options = {})
    super
  end

  def parse
    super do
      items = nil
    end
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

  logger = Logger.new(STDOUT)

  scrapper = Scrapper.new(
    target_url,
    list_page_class: PetsonicListPage,
    item_page_class: ItemPage,
    logger: logger
  )

  scrapper.parse
end

main
