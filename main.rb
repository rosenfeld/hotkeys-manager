require 'sinatra/base'
require 'sinatra/reloader'

require_relative 'lib/hotkeys_manager'

class Main < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index, layout: false, locals: { hotkeys: HotkeysManager.hotkeys }
  end

  post '/toggle/:id' do
    HotkeysManager.toggle Integer(params[:id])
    halt 200
  end

  post '/update_name/:id' do
    HotkeysManager.update_name Integer(params[:id]), params[:name]
    halt 200
  end

  post '/update_key/:id' do
    HotkeysManager.update_key Integer(params[:id])
    redirect '/'
  end

  post '/capture' do
    HotkeysManager.grab_window
    redirect '/'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
