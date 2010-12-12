require 'helper'
require 'anvl/erc'

class TestErc < Test::Unit::TestCase
  def test_parse_empty
    h = ANVL::Erc.parse ''
    assert_equal(0, h.entries.length)
  end

  def test_basic
    str = 'erc:
who:    Lederberg, Joshua
what:   Studies of Human Families for Genetic Linkage
when:   1974
where:  http://profiles.nlm.nih.gov/BB/AA/TT/tt.pdf
note:   This is an arbitrary note inside a
        small descriptive record.'
    h = ANVL::Erc.parse str
    assert_equal("", h[:erc])
  end

  def test_intl
    str = 'erc:
who:    Lederberg, Joshua
h2:   Studies of Human Families for Genetic Linkage'
    h = ANVL::Erc.parse str
    assert_equal("Lederberg, Joshua", h[:who])
    assert_equal("Lederberg, Joshua", h['who'])
    assert_equal("Lederberg, Joshua", h[:h1])
    assert_equal("Lederberg, Joshua", h['wer(h1)'])
    assert_equal("Studies of Human Families for Genetic Linkage", h[:h2])
    assert_equal("Studies of Human Families for Genetic Linkage", h[:what])
    assert_equal("Studies of Human Families for Genetic Linkage", h['was(h2)'])
  end

  def test_comparison
    str = 'erc:'
    h = ANVL::Erc.parse str

    h['marc_856'] = 'abc'

    assert_equal("abc", h['marc_856'])
    h['MARC 856'] = '123'

    assert_equal("123", h['marc_856'])
  end
end
