require 'logger'
require 'byebug'

require_relative 'lib/scrapper'
require_relative 'lib/list_page'
require_relative 'lib/item_page'

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

  def item_link_elements
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

class PetsonicItemPage < ItemPage
  def initialize(url, options = {})
    super
    @header_class = options[:header_class] || 'product-name'
    @image_id = options[:image_class] || 'image-block'
    @price_class = options[:price_class] || 'attribute_labels_lists'
  end

  def header_element
    super do |document|
      document
        .all
        .tag(:div)
        .class_name(@header_class)
        .children
        .tag(:h1)
        .get
    end
  end

  def image_element
    super do |document|
      document
        .all
        .tag(:div)
        .id(@image_id)
        .all
        .tag(:img)
        .get
    end
  end

  def prices
    super do |document|
      variations = document
        .all
        .tag(:ul)
        .class_name(@price_class)
        .children
        .tag(:li)
        .select

      variations.map { |item| { name: item.element_children[0], price: item.element_children[1] } }
    end
  end
end

def main
  target_url = ARGV.first

  logger = Logger.new(STDOUT)

  scrapper = Scrapper.new(
    target_url,
    list_page_class: PetsonicListPage,
    item_page_class: PetsonicItemPage,
    logger: logger
  )

  res = scrapper.parse
  p res
  puts res
end

main
