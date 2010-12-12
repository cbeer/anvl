require 'helper'

class TestErcElement < Test::Unit::TestCase
  def test_basic
    h = ANVL::Erc::Element.new :label => 'abc', :value => '123'
    assert_equal('123', h.to_s)
    assert_equal('abc: 123', h.to_anvl)
  end

  def test_initial_comma_to_recover_natural_word_order
    h = ANVL::Erc::Element.new :label => 'abc', :value => ',  van Gogh, Vincent'
    assert_equal('Vincent van Gogh', h.to_s)
    assert_equal('abc:,  van Gogh, Vincent', h.to_anvl)

    h = ANVL::Erc::Element.new :label => 'abc', :value => ',  Howell, III, PhD, 1922-1987, Thurston'
    assert_equal('Thurston Howell, III, PhD, 1922-1987', h.to_s)
    assert_equal('abc:,  Howell, III, PhD, 1922-1987, Thurston', h.to_anvl)

    h = ANVL::Erc::Element.new :label => 'abc', :value => ',  McCartney, Paul, Sir,'
    assert_equal('Sir Paul McCartney', h.to_s)
    assert_equal('abc:,  McCartney, Paul, Sir,', h.to_anvl)
  end
end
