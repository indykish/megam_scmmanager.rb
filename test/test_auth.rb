require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestScm < MiniTest::Unit::TestCase

 
 def test_get_json    
    response =megams.get_repos()
    assert_equal(200, response.status)
  end 

end


