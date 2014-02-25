module Megam
  class Scmmanager
    # GET /accounts
    #Yet to be tested
    def get_repos(username, password)

      @options = {:path => "/repositories",
        :body => ''}.merge(@options)

      request(
        :expects  => 200,
        :method   => :get,
        :username => username,
        :password => password,
        :body     => @options[:body]
      )
    end 
    
  end
end
