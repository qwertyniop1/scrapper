require 'nokogiri'

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

  def class_name(value)
    attribute(:class, value)
  end

  def id(value)
    attribute(:id, value)
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
