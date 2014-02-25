require File.expand_path("#{File.dirname(__FILE__)}/../lib/megam/scm")

require 'rubygems'
gem 'minitest' # ensure we are using the gem version
require 'minitest/autorun'
require 'time'

SANDBOX_HOST_OPTIONS = {
  :host => 'scm-manager.megam.co',
  :port => 8080
}


def megam(options)  
  options = SANDBOX_HOST_OPTIONS.merge(options)
  mg=Megam::Scm.new(options)  
end

def megams(options={})  
s_options = SANDBOX_HOST_OPTIONS.merge(options)
  #options = s_options.merge(options)
  mg=Megam::Scm.new(s_options)  
end

def sandbox_json
 {:json =>
    '{"name":"raj", "displayName":"test", "mail":"rajthilak@megam.co.in", "password":"welcome"}'
  }
end
