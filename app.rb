require "sinatra/base"


class App < Sinatra::Base
  set :views, settings.root + '/app/views'

  get '/'  do
    erb :index
  end
end
