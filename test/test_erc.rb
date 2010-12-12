require 'helper'
require 'anvl/erc'

class TestErc < Test::Unit::TestCase
  def test_parse_empty
    h = ANVL::Erc.parse ''
    assert_equal(0, h.entries.length)
  end

  def test_basic
    str = 'erc:
who:    Gibbon, Edward
what:   The Decline and Fall of the Roman Empire
when:   1781
where:  http://www.ccel.org/g/gibbon/decline/'

    h = ANVL::Erc.parse str
    assert_equal("", h[:erc])
    assert_equal("Gibbon, Edward", h[:who])
    assert_equal("The Decline and Fall of the Roman Empire", h[:what])
    assert_equal("1781", h[:when])
    assert_equal("http://www.ccel.org/g/gibbon/decline/", h[:where])
  end  

  def test_complete
    str = 'erc:
what:    The Digital Dilemma
where:  http://books.nap.edu/html/digital%5Fdilemma
    '

    h = ANVL::Erc.parse str
    assert_equal(false, h.complete?)

    h[:who] = '---'
    h[:when] = '---'
    assert(h.complete?)
  end

  def test_complete_meta
    str = 'meta-erc:  NLM | pm9546494 | 19980418
               | http://ark.nlm.nih.gov/12025/pm9546494??'
    h = ANVL::Erc.parse str
    assert(h.complete?)
  end

  def test_missing_about
    str = 'about-erc:   | Bispectrum ; Nonlinearity ; Epilepsy
                   ; Cooperativity ; Subdural ; Hippocampus'
    h = ANVL::Erc.parse str
    assert_contains(h['about-what'], 'Bispectrum')
    assert_contains(h['about-what'], 'Nonlinearity')
    assert_contains(h['about-what'], 'Epilepsy')
    assert_contains(h['about-what'], 'Cooperativity')
    assert_contains(h['about-what'], 'Subdural')
    assert_contains(h['about-what'], 'Hippocampus')
  end

  def test_abbr
    str = 'erc: Gibbon, Edward | The Decline and Fall of the Roman Empire
         | 1781 | http://www.ccel.org/g/gibbon/decline/'

    h = ANVL::Erc.parse str
    assert_equal("Gibbon, Edward", h[:who])
    assert_equal("The Decline and Fall of the Roman Empire", h[:what])
    assert_equal("1781", h[:when])
    assert_equal("http://www.ccel.org/g/gibbon/decline/", h[:where])
  end

  def test_multiple_values
    str = 'erc:
who:  Smith, J; Wong, D; Khan, H'
    h = ANVL::Erc.parse str

    assert_contains(h[:who], 'Smith, J')
    assert_contains(h[:who], 'Wong, D')
    assert_contains(h[:who], 'Khan, H')
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

  def test_label_structure
    str = 'erc:'
    h = ANVL::Erc.parse str

    h['marc_856'] = 'abc'

    assert_equal("abc", h['marc_856'])
    h['MARC 856'] = '123'

    assert_equal("123", h['marc_856'])
  end

  def test_initial_comma
    str = 'erc:
who:,  van Gogh, Vincent
who:,  Howell, III, PhD, 1922-1987, Thurston
who:,  Acme Rocket Factory, Inc., The
who:,  Mao Tse Tung
who:,  McCartney, Pat, Ms,
who:,  McCartney, Paul, Sir,
who:,  McCartney, Petra, Dr,
what:, Health and Human Services, United States Government
    Department of, The,'

    h = ANVL::Erc.parse str
    assert_contains(h[:who], "Vincent van Gogh")
    assert_contains(h[:who], "Thurston Howell, III, PhD, 1922-1987")
    assert_contains(h[:who], "The Acme Rocket Factory, Inc.")
    assert_contains(h[:who], "Mao Tse Tung")
    assert_contains(h[:who], "Ms Pat McCartney")
    assert_contains(h[:who], "Sir Paul McCartney")
    assert_contains(h[:who], "Dr Petra McCartney")
    assert_equal(h[:what], "The United States Government Department of Health and Human Services")
  end
end
