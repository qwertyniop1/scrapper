require 'curb'

require_relative 'null_logger'
require_relative 'html_document'

def get_html(url)
  http = Curl.get(url)
  http.body_str
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
