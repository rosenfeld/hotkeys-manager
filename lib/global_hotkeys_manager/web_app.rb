require 'sinatra/base'
require 'sinatra/reloader'
require 'tilt/erb'

require_relative '../global_hotkeys_manager'

module GlobalHotkeysManager
  class WebApp < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    configure do
      set :port, GlobalHotkeysManager::PORT
      set :bind, GlobalHotkeysManager::HOST
    end

    get '/' do
      erb :index, layout: false, locals: { hotkeys: GlobalHotkeysManager.hotkeys }
    end

    post '/toggle/:id' do
      GlobalHotkeysManager.toggle Integer(params[:id])
      halt 200
    end

    post '/update_name/:id' do
      GlobalHotkeysManager.update_name Integer(params[:id]), params[:name]
      halt 200
    end

    post '/update_key/:id' do
      GlobalHotkeysManager.update_key Integer(params[:id])
      redirect '/'
    end

    post '/capture' do
      GlobalHotkeysManager.grab_window
      redirect '/'
    end
  end
end
