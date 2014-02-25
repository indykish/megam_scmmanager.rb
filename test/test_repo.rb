require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestScm < MiniTest::Unit::TestCase

  #def test_post_json    
   # response =megams.post_accounts(sandbox_json)
    #assert_equal(200, response.status)
  #end
  
 # def test_get_json    
  #  response =megams.get_repos()
 #   assert_equal(200, response.status)
 # end

  def test_login
    response= megams.get_login("scmadmin", "scmadmin", true)
  end

end


