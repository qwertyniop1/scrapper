require_relative '../scrapper/item_page'

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
        .children
        .last
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

      return [{ price: document.all.tag(:span).id('price_display').get }] if variations.empty?

      variations.map { |item| { name: item.element_children[0], price: item.element_children[1] } }
    end
  end
end
