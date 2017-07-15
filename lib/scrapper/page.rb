require_relative 'null_logger'
require_relative 'html_document'
require_relative 'network'

class Page
  attr_reader :payload

  def initialize(url, options = {})
    @url = url
    @document = nil
    @payload = []
    @logger = options[:logger] || NullLogger.new
    @options = options
  end

  def parse
    tries = @options[:request_tries] || 5
    timeout = @options[:request_timeout] || 30
    html = fetch(@url, tries, timeout, @logger)
    return nil if html.nil?

    @document = HTMLDocument.new(html)

    begin
      @payload = yield if block_given?
    rescue => error
      @logger.error 'An error occured during parsing'
      @logger.debug error.message
    end
    self
  end

  def to_s
    "#<#{self.class} @url='#{@url}'>"
  end
end
