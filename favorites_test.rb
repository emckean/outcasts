require "test/unit"
require_relative 'favorites'

class TextFavorites < Test::Unit::TestCase
 
  def test_simple
    assert_equal(4, 4)
  end
  
  def test_find_word_at_beginning_of_text
    result = Result.new "This is my favorite word"
    assert result.valid?
    assert_equal "this", result.word
  end
  
  def test_find_word_within_text
    result = Result.new "Hey guys, dingo is my favorite word"
    assert result.valid?
    assert_equal "dingo", result.word
  end

  def test_find_word_within_double_quotes
    result = Result.new "12345 &(*& zomg \"Skyzzz\" is my favorite word"
    assert result.valid?
    assert_equal "skyzzz", result.word
  end

  def test_find_word_within_single_quotes
    result = Result.new "Some people say that 'irregardless' is my favorite word."
    assert result.valid?
    assert_equal "irregardless", result.word
  end
  
  def test_word_not_present
    result = Result.new "This tweet doesn't even have the right substring..."
    assert !result.valid?
  end
 
end
