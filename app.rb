require "sinatra/base"
require_relative "app/upload"

class App < Sinatra::Base
  SAVE_PATH = settings.root + "/uploads"

  set :views, settings.root + '/app/views'
  set :server, "thin"

  get "/"  do
    erb :index
  end

  get "/editor" do
    erb :editor
  end

  # TODO
  post '/upload' do
     upload_result = Upload.handle_request(params, SAVE_PATH)

     if upload_result.has_key? :error
       # TODO handle error
       puts upload_result
     else
       # TODO handle success
       puts upload_result
     end
  end
end
