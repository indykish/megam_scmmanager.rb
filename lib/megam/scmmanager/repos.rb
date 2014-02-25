module Megam
  class Scm
    # GET /accounts
    #Yet to be tested
    def get_repos()

      @options = {:path => "/repositories",
        :body => ''}.merge(@options)

      request(
        :expects  => 200,
        :method   => :get,
        :body     => @options[:body]
      )
    end
    
    def get_login(username, password, rememberme)

      @options = {:path => "/authentication/login",
        :body => '', :query => {:username => username, :password => password, :rememberMe => rememberme} }.merge(@options)

      request(
        :expects  => 200,
        :method   => :post,
        :body     => @options[:body]
      )
    end
    
  end
end
