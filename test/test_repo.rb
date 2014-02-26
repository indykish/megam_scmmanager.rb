require File.expand_path("#{File.dirname(__FILE__)}/test_helper")
require 'nokogiri'

class TestScm < MiniTest::Unit::TestCase
  def test_getrepos
    response =megams.get_repos()
    assert_raises(ArgumentError)
  end

  def test_getrepos_error
    response =megams.get_repos("abcd", "abcd")
    assert_raises(ArgumentError)
  end

end

