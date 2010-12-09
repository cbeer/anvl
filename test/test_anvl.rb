require 'helper'

class TestAnvl < Test::Unit::TestCase
  def test_parse_empty
    h = ANVL.parse ''
    assert_equal(0, h.entries.length)
  end

  def test_parse_comment
    h = ANVL.parse '#'
    assert_equal(0, h.entries.length)
  end

  def test_first_draft
    h = ANVL.parse 'entry: 
# first draft 
who: Gilbert, W.S. | Sullivan, Arthur 
what: The Yeomen of
      the Guard 
when/created: 1888'
    assert_equal("", h[:entry])
    assert_equal('Gilbert, W.S. | Sullivan, Arthur', h[:who])
    assert_equal("The Yeomen of the Guard", h[:what])
    assert_equal("1888", h[:"when/created"])
  end

  def test_multiple_values
    h = ANVL::Document.parse 'entry:
a: 1
a: 2'
    assert_equal({:a => ["1","2"], :entry => ""}, h.to_h)
  end

  def test_key_access
    h = ANVL::Document.new
    assert_equal([], h[:a])
    h[:a] = 'a'
    assert_equal({:a => 'a' }, h.to_h)
    h[:a] = ['a', 'b']
    assert_equal({:a => ['a', 'b'] }, h.to_h)
    h[:a] << 'c'
    assert_equal({:a => ['a', 'b', 'c'] }, h.to_h)
    assert_equal(['a', 'b', 'c'], h[:a])

    h[:b]
    assert_equal({:a => ['a', 'b', 'c'] }, h.to_h)

    h << { :a => 'd' }
    assert_equal({:a => ['a', 'b', 'c', 'd'] }, h.to_h)

    h << { :c => 1 }
    assert_equal(1, h[:c])

    h << { :c => 2 }
    assert_equal([1, 2], h[:c])

    str = h.to_s
    assert_match(/^a: a$/, str)
    assert_match(/^a: b$/, str)
    assert_match(/^a: c$/, str)
    assert_match(/^a: d$/, str)
    assert_match(/^c: 1$/, str)
    assert_match(/^c: 2$/, str)
  end

  def test_newlines
    h = ANVL::Document.new
    h[:nl] = "abc\n123"
    assert_equal("nl: abc\n    123", h.to_s)
  end

  def test_fmt_empty
    str = ANVL.to_anvl({})
    assert_equal('', str)
  end
  
  def test_fmt_first_draft
    str = ANVL.to_anvl({:entry => [""], :who => ['Gilbert, W.S. | Sullivan, Arthur'], :what => ["The Yeomen of the Guard"], :"when/created" => [1888]})
    assert_match(/entry:/, str)
    assert_match(/who: Gilbert, W.S. | Sullivan, Arthur/, str)
    assert_match(/what: The Yeomen of the Guard/, str)
    assert_match(/when\/created: 1888/, str)
  end
end
