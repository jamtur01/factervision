require 'rubygems'
require 'logger'
require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/static_assets'
require 'sinatra/flash'
require 'json'
require 'version'
require 'factervision/models'

module FacterVision
  class Application < Sinatra::Base

    register Sinatra::StaticAssets
    register Sinatra::Flash

    configure :production do
      log = File.new("log/production.log", "a")
      STDOUT.reopen(log)
      STDERR.reopen(log)
    end

    enable :logging, :dump_errors, :raise_errors, :show_exceptions

    enable :sessions

    not_found do
      "Page not found"
    end

    before do
      @app_name = "FacterVision"
      @version = FacterVision::VERSION
    end

    get '/' do
      erb :index
    end

    get '/about' do
      erb :about
    end

    get '/api' do
      erb :api
    end

    get '/signup' do
      erb :signup
    end

    post '/signup/add' do
      logger.info "Received signup request for #{params[:email]}"
      @email = FacterVision::Token.signup(params[:email])
      if @email.saved?
        logger.info "Created signup request for #{params[:email]}"
        key = FacterVision::Token.get_token_email(params[:email]).access_token
        flash[:info] = "Thank you for registering #{params[:email]}. Your API key is #{key}"
        redirect "/signup"
      else
        errors = @email.errors.values.map{|e| e.to_s}
        logger.info "Failed signup request for #{params[:email]} with #{errors}."
        flash[:error] = errors
        redirect "/signup"
      end
    end

    post "/upload/?" do
      requires_params :facts, :key
      halt 401, {'Content-Type' => 'text/plain'}, 'No matching API key found' unless FacterVision::Token.get_user(params[:key])
      logger.info "Received API upload call."
      @facts = FacterVision::Fact.add_facts(params[:facts], params[:key])
      if @facts.saved?
        logger.info "Created facts request."
        halt 200, {'Content-Type' => 'text/plain'}, "Facts processed"
      else
        halt 500, {'Content-Type' => 'text/plain'}, @facts.errors.values.map{|e| e.to_s}
      end
    end

    get "/show/?" do
      requires_params :key
      halt 401, {'Content-Type' => 'text/plain'}, 'No matching API key found' unless FacterVision::Token.get_user(params[:key])
      logger.info "Received API show call for #{params[:key]}."
      @results = FacterVision::Fact.get_facts(params[:key])
      @email = FacterVision::Token.get_user(params[:key])
      erb :show
    end

    helpers do
     def requires_params(*needed)
        halt 400, 'No parameters specified' if params.empty?

        needed.each do |param|
          unless params[param]
            halt 400, {'Content-Type' => 'text/plain'}, "You must specify #{param.to_s} as a parameter."
          end
        end
      end
      alias :requires_param :requires_params
    end
  end
end
