require_relative 'page'

class ListPage < Page
  def initialize(url, options = {})
    super
    @page_class = options[:item_page_class] || Page
  end

  def parse
    super do
      links = item_link_elements
      @logger.info "Found #{links.size} links at #{@url}:"
      urls = links.each_with_index.map do |link, index|
        url = link[:href]
        @logger.info "\t#{index + 1}: #{url}"
        url
      end
      urls.map do |url|
        @page_class.new(url, @options).parse.payload
      end
    end
  end

  def pages_count(count = 0)
    if block_given?
      begin
        yield(@document).text.to_i
      rescue
        0
      end
    else
      count
    end
  end

  def item_link_elements
    raise ArgumentError, 'No block given' unless block_given?
    yield @document
  end
end
