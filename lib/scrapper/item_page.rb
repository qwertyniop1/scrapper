require_relative 'page'

class ItemPage < Page
  def initialize(url, options = {})
    super
  end

  def parse
    super do
      header = header_element.text
      image = image_element[:src]

      prices.map do |item|
        item[:name] = item[:name] ? "#{header} - #{item[:name].text}" : header
        item[:image] = image
        item[:price] = item[:price].text.strip
        item
      end
    end
  end

  def header_element
    raise ArgumentError, 'No block given' unless block_given?
    yield @document
  end

  def image_element
    raise ArgumentError, 'No block given' unless block_given?
    yield @document
  end

  def prices
    raise ArgumentError, 'No block given' unless block_given?
    yield @document
  end
end
