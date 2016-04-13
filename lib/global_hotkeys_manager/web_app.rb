require 'sinatra/base'
require 'tilt/erb'

require_relative '../global_hotkeys_manager'

module GlobalHotkeysManager
  class WebApp < Sinatra::Base
    configure do
      set :environment, :production
      set :port, GlobalHotkeysManager::PORT
      set :bind, GlobalHotkeysManager::HOST
      if GlobalHotkeysManager::SETTINGS[:debug]
        set :environment, :development
        begin
          require 'sinatra/reloader'
          register Sinatra::Reloader
        rescue Exception => e
          puts 'For auto-reload to work sinatra-contrib gem must be installed'
        end
      end
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
