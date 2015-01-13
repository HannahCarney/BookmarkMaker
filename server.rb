require 'sinatra/base'
require 'data_mapper'
require 'tag'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'

DataMapper.finalize

DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Base

  get '/' do
    @links = Link.all
		erb :index	
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    Link.create(:url => url, :title => title)
    redirect to ('/')
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
