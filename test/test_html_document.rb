require 'test_helper'

require 'html_document'

class TestHTMLDocument < MiniTest::Unit::TestCase
  def setup
    html = <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>The HTML5 Herald</title>
  <meta name="description" content="The HTML5 Herald">
  <meta name="author" content="SitePoint">
  <link rel="stylesheet" href="css/styles.css?v=1.0">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.js"></script>
</head>
<body>
  <script src="js/scripts.js"></script>
</body>
</html>
HTML

    @document = HTMLDocument.new(html)
  end

  def test_initial_query_is_empty
    assert_equal @document.verbose, ''
  end

  def test_query
    @document.query('selector')
    assert_equal @document.verbose, 'selector'
  end

  def test_all
    @document.all
    assert_equal @document.verbose, '//'
  end

  def test_children
    @document.children
    assert_equal @document.verbose, '/'
  end

  def tag
    @document.tag(:my_tag)
    assert_equal @document.verbose, 'my_tag'
  end

  def test_attribute
    @document.attribute(:attribute, 5)
    assert_equal @document.verbose, "[contains(concat(' ', @attribute, ' '), ' 5 ')]"
  end

  def test_class_name
    @document.class_name('test')
    assert_equal @document.verbose, "[contains(concat(' ', @class, ' '), ' test ')]"
  end

  def test_attribute
    @document.id('test')
    assert_equal @document.verbose, "[contains(concat(' ', @id, ' '), ' test ')]"
  end

  def test_first
    @document.first
    assert_equal @document.verbose, '[1]'
  end

  def test_last
    @document.last
    assert_equal @document.verbose, '[last()]'
  end

  def test_methods_chaining
    @document.all.class_name('class-test').first.children.last
    assert_equal @document.verbose, "//[contains(concat(' ', @class, ' '), ' class-test ')][1]/[last()]"
  end

  def test_select
    selection = @document.tag(:html).children.tag(:head).children.tag(:meta).select
    assert_equal selection.size, 3
    assert_equal selection.first['charset'], 'utf-8'
    assert_equal selection.last['content'], 'SitePoint'
  end

  def test_select_not_existing
    selection = @document.tag(:html).children.tag(:wrong).select
    assert selection.empty?
  end

  def test_reset_query_after_select
    selection = @document.tag(:html).children.tag(:wrong).select
    assert @document.verbose, ''
  end

  def test_get
    selection = @document.tag(:html).children.tag(:head).children.tag(:title).get
    assert_equal selection.text, 'The HTML5 Herald'
  end

  def test_get_not_existing
    selection = @document.tag(:html).children.tag(:wrong)
    assert_raises(HTMLDocumentError) { selection.get }
  end

  def test_reset_query_after_get
    selection = @document.tag(:html).children.tag(:head).get
    assert @document.verbose, ''
  end
end
