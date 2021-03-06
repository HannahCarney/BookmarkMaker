require 'sinatra/base'
require 'rack-flash'
require 'data_mapper'
require 'sass'
require 'pony'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'
require './lib/tag'
require './lib/user'

DataMapper.finalize

DataMapper.auto_upgrade!


class BookmarkManager < Sinatra::Base

  helpers do

    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end

  end

  enable :sessions
  set :sessions_secret, 'super secret'
  use Rack::Flash
  use Rack::MethodOverride


  get '/' do
    @links = Link.all
		erb :index	
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(" ").map{|tag| Tag.first_or_create(:text => tag)}
    Link.create(:url => url, :title => title, :tags => tags)
    redirect to ('/')
  end

  get '/tags/:text' do
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :"users/new"
  end

  post '/users' do
    @user = User.new(:email => params[:email],
                     :password => params[:password],
                     :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/new"
    end
  end

  get '/sessions/new' do
    erb :"sessions/new" #has form on it
  end


  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ["The email or password is incorrect"]
      erb :"sessions/new"
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash[:notice] = "Goodbye!"
    redirect to('/')
  end

  post '/sessions/reminder' do
    user = User.first(:email => params[:email])
    user.password_token = user.create_token
    user.password_token_timestamp = Time.now
    user.save
    user.send_email(user.password_token)
    redirect '/sessions/new'
  end

  get '/sessions/request_token' do
    erb :"sessions/request_token"
  end

  get '/users/reset_password/:token' do
    user = User.first(:password_token => params[:token])
    @password_token = user.password_token
    erb :"sessions/change_password"
  end

  post '/sessions/password_reset' do
    user = User.first(:password_token => params[:password_token])
    user.update(:password => params[:password], :password_confirmation => params[:password_confirmation])
    redirect ('/')
  end

  run! if app_file == $0

end
