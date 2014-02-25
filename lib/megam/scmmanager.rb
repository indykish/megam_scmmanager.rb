require "time"
require "excon"
require "uri"
require "zlib"
require 'openssl'


__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
$LOAD_PATH.unshift(__LIB_DIR__)
end

require "megam/scmmanager/version"
require "megam/scmmanager/accounts"
require "megam/scmmanager/errors"
require "megam/scmmanager/repos"
require "megam/core/json_compat"
require "megam/core/stuff"
require "megam/core/text"
require "megam/core/account"
require "megam/core/error"

module Megam
  class Scm

    #text is used to print stuff in the terminal (message, log, info, warn etc.)
    attr_accessor :text

    HEADERS = {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip',
      'User-Agent' => "megam-scmmanager/#{Megam::Scm::VERSION}",
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
    AUTH_PATH="authentication/login"

    def text
      @text ||= Megam::Text.new(STDOUT, STDERR, STDIN, {})
    end

    def last_response
      @last_response
    end

    # It is assumed that every API call will NOT use an API_KEY/email. 
    def initialize(options={})       
	@options = OPTIONS.merge(options)       
    end

    def request(params,&block)
      start = Time.now
      text.msg "#{text.color("START", :cyan, :bold)}"
      params.each do |pkey, pvalue|
        text.msg("> #{pkey}: #{pvalue}")
      end

      
      begin
        response = connection.request(params, &block)
      rescue Excon::Errors::HTTPStatusError => error
        klass = case error.response.status

        when 401 then Megam::Scm::Errors::Unauthorized
        when 403 then Megam::Scm::Errors::Forbidden
        when 404 then Megam::Scm::Errors::NotFound
        when 408 then Megam::Scm::Errors::Timeout
        when 422 then Megam::Scm::Errors::RequestFailed
        when 423 then Megam::Scm::Errors::Locked
        when /50./ then Megam::Scm::Errors::RequestFailed
        else Megam::Scm::Errors::ErrorWithResponse
        end
        reerror = klass.new(error.message, error.response)
        reerror.set_backtrace(error.backtrace)
        text.msg "#{text.color("#{reerror.response.body}", :white)}"
        reerror.response.body = Megam::JSONCompat.from_json(reerror.response.body.chomp)
        text.msg("#{text.color("RESPONSE ERR: Ruby Object", :magenta, :bold)}")
        text.msg "#{text.color("#{reerror.response.body}", :white, :bold)}"
        raise(reerror)
      end

      @last_response = response
      text.msg("#{text.color("RESPONSE: HTTP Status and Header Data", :magenta, :bold)}")
      text.msg("> HTTP #{response.remote_ip} #{response.status}")

      response.headers.each do |header, value|
        text.msg("> #{header}: #{value}")
      end
      text.info("End HTTP Status/Header Data.")

      if response.body && !response.body.empty?
        if response.headers['Content-Encoding'] == 'gzip'
          response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
        end
        text.msg("#{text.color("RESPONSE: HTTP Body(JSON)", :magenta, :bold)}")

        text.msg "#{text.color("#{response.body}", :white)}"

        begin
          text.msg("#{text.color("RESPONSE: 2 -> Ruby ", :magenta, :bold)}")

          text.msg "#{text.color("#{response.body}", :white, :bold)}"
        rescue Exception => jsonerr
          text.error(jsonerr)
          raise(jsonerr)
         end
      end
      text.msg "#{text.color("END(#{(Time.now - start).to_s}s)", :blue, :bold)}"
      # reset (non-persistent) connection
      @connection.reset
      response.body
    end
    private

    #Make a lazy connection.
    def connection      
      auth
      @options[:path] =API_REST+ @options[:path]
      @options[:headers] = HEADERS.merge({
             'X-Megam-Date' =>  Time.now.strftime("%Y-%m-%d %H:%M")
      }).merge(@options[:headers])

      text.info("HTTP Request Data:")
      text.msg("> HTTP #{@options[:scheme]}://#{@options[:host]}")
      @options.each do |key, value|
        text.msg("> #{key}: #{value}")
      end
      text.info("End HTTP Request Data.")
      text.info("#{@options[:scheme]}://#{@options[:host]}:#{@options[:port]}")
      
      @connection = Excon.new("#{@options[:scheme]}://#{@options[:host]}:#{@options[:port]}",@options)
    end

   def auth
      authoptions = {}
      authoptions[:path] =API_REST+ AUTH_PATH
      authoptions[:headers] = HEADERS.merge({
      "Content-Type" => "application/x-www-form-urlencoded",
       "username" => ENV['MEGAM_SCMADMIN_USERNAME'],
       "password" => ENV['MEGAM_SCMADMIN_PASSWORD'],
       "rememberMe" => true,             
      }).merge(@options[:headers])

      text.info("HTTP Auth Request Data:")
      text.msg("> HTTP #{authoptions[:scheme]}://#{authoptions[:host]}")
      authoptions.each do |key, value|
        text.msg("> #{key}: #{value}")
      end
      text.info("End HTTP Auth Request Data.")
      text.info("#{authoptions[:scheme]}://#{authoptions[:host]}:#{authoptions[:port]}")
      
      authcon = Excon.new("#{authoptions[:scheme]}://#{authoptions[:host]}:#{authoptions[:port]}",authoptions, :persistent => true)
      authcon.request(authoptions)
    end


    
  end

end
