require "time"
require "uri"
require "zlib"
require 'openssl'
require 'net/http'

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
$LOAD_PATH.unshift(__LIB_DIR__)
end

require "megam/scmmanager/version"
require "megam/scmmanager/accounts"
require "megam/scmmanager/dumpout"
require "megam/scmmanager/errors"
require "megam/scmmanager/repos"
require "megam/core/scmm/scmmrepo"
require "megam/core/scmm/scmmaccount"

module Megam
  class Scmmanager

    HEADERS = {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip',
      'User-Agent' => "megam-scmmanager/#{Megam::Scmmanager::VERSION}",
      'X-Ruby-Version' => RUBY_VERSION,
      'X-Ruby-Platform' => RUBY_PLATFORM
    }

    OPTIONS = {
      :headers => {},
      :host => 'scm-manager.megam.co',
      :port => '8080',
      :nonblock => false,
      :scheme => 'http'
    }

    API_REST = "/scmmanager/api/rest"
    AUTH_PATH="/authentication/login"

    def text
      @text ||= Megam::Dumpout.new(STDOUT, STDERR, STDIN)
    end

    def last_response
      @last_response
    end

    # It is assumed that every API call will NOT use an API_KEY/email.
    def initialize(options={})
      @options = OPTIONS.merge(options)
    end

    def request(params, &block)
      start = Time.now
      puts params
      text.msg "#{text.color("START", :cyan, :bold)}"
      username =  params[:username] || ENV['MEGAM_SCMADMIN_USERNAME']
      password =  params[:password]  || ENV['MEGAM_SCMADMIN_PASSWORD']
      raise ArgumentError, "You must specify [:username, :password]" if username.nil? || password.nil?
      text.msg "#{text.color("Got username[#{username}] [*******]", :red, :bold)}"

      begin
        httpcon = connection
        httpcon.use_ssl = false
        httpcon.start do |http|
          request = Net::HTTP::Get.new(@options[:path])
          request.basic_auth username, password
          @response = http.request(request)
        end
      end
      @response
    end
    private

    #Make a lazy connection.
    def connection
      @options[:path] =API_REST + @options[:path]
      @options[:headers] = HEADERS.merge({
        'X-Megam-Date' =>  Time.now.strftime("%Y-%m-%d %H:%M")
      }).merge(@options[:headers])

      text.info("HTTP Request Data:")
      text.msg("> HTTP #{@options[:scheme]}://#{@options[:host]}")
      @options.each do |key, value|
        text.msg("> #{key}: #{value}")
      end
      text.info("End HTTP Request Data.")
      http = Net::HTTP.new(@options[:host], @options[:port])
      http
    end
  end

end
