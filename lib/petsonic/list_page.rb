require_relative '../scrapper/list_page'

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
