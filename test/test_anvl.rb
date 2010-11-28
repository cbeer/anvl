require 'helper'

class TestAnvl < Test::Unit::TestCase
  def test_parse_empty
    h = ANVL.parse ''
    assert_equal(h.entries.length, 0)
  end

  def test_parse_comment
    h = ANVL.parse '#'
    assert_equal(h.entries.length, 0)
  end

  def test_first_draft
    h = ANVL.parse 'entry: 
# first draft 
who: Gilbert, W.S. | Sullivan, Arthur 
what: The Yeomen of
      the Guard 
when/created: 1888'
    assert_equal(h[:entry], "")
    assert_equal(h[:who], 'Gilbert, W.S. | Sullivan, Arthur')
    assert_equal(h[:what], "The Yeomen of the Guard")
    assert_equal(h[:"when/created"], "1888")
  end

  def test_fmt_empty
    str = ANVL.to_anvl({})
    assert_equal(str, '')
  end
  
  def test_fmt_first_draft
    str = ANVL.to_anvl({:entry => [""], :who => ['Gilbert, W.S. | Sullivan, Arthur'], :what => ["The Yeomen of the Guard"], :"when/created" => [1888]})
    assert_match(/entry:/, str)
    assert_match(/who: Gilbert, W.S. | Sullivan, Arthur/, str)
    assert_match(/what: The Yeomen of the Guard/, str)
    assert_match(/when\/created: 1888/, str)
  end
end
