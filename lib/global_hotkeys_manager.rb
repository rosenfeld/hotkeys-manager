require 'json'
require 'fileutils'

require_relative 'global_hotkeys_manager/version'

module GlobalHotkeysManager
  CONFIG_DIR = File.expand_path '~/.config/global-hotkeys-manager'
  XBINDKEYSRC = "#{CONFIG_DIR}/xbindkeysrc"
  HOTKEYS_JSON = "#{CONFIG_DIR}/hotkeys.json"
  PORT = ENV['HOTKEYS_MANAGER_PORT'] || 4242
  HOST = '127.0.0.1'
  URL_BASE = "http://#{HOST}:#{PORT}"

  FileUtils.mkdir_p CONFIG_DIR

  def self.pid
    return unless pid = `pgrep -o -f xbindkeys.*hotkeys`.split("\n").find{|p| system "kill -0 #{p}"}
    system("kill -0 #{pid}") and pid.to_i
  end

  def self.ensure_running
    id = pid and `kill #{id}`
    `[ -f #{XBINDKEYSRC} ] && xbindkeys -f #{XBINDKEYSRC}`
  end

  def self.stop
    pid and `kill #{pid}`
  end

  def self.hotkeys
    return [] unless File.exist? HOTKEYS_JSON
    JSON.parse(File.read HOTKEYS_JSON).find_all do |(id, name, key, mapped)|
      valid_window_id?(id)
    end
  end

  def self.valid_window_id?(id)
    system "xwininfo -id #{id} > /dev/null 2>&1"
  end

  def self.map_all
    hotkeys.each do |(id, name, key, mapped)|
      `xdotool windowmap #{id}` rescue nil
    end
  end

  def self.toggle(wid)
    new_state = []
    hotkeys.each do |(id, name, key, mapped)|
      if id == wid
        mapped = !mapped
        if mapped
          `xdotool windowmap #{id}`
          `xdotool windowactivate #{id}`
        else
          `xdotool windowunmap #{id}`
        end
      end
      new_state.push [id, name, key, mapped]
    end
    update_config new_state
  end

  def self.update_config(hotkeys)
    hotkeys = hotkeys.find_all{|(id, name, key, mapped)| valid_window_id? id}
    File.write HOTKEYS_JSON, JSON.unparse(hotkeys)
    File.write XBINDKEYSRC, hotkeys.map{|(id, name, key, mapped)|
      # webrick has a bug and require content-length to be sent
      # using curl is faster but in case it's not installed we fall back to the command line
      %Q{\##{name}\n"curl -H 'Content-Length: 0' -X POST #{URL_BASE}/toggle/#{id} || global_hotkeys_manager toggle #{id}"\n#{key}\n}
    }.join("\n\n")
    ensure_running
  end

  def self.update_name(wid, new_name)
    new_state = []
    hotkeys.each do |(id, name, key, mapped)|
      name = new_name if id == wid
      new_state.push [id, name, key, mapped]
    end
    update_config new_state
  end

  def self.update_key(wid)
    new_key = ask_for_key
    new_state = []
    hotkeys.each do |(id, name, key, mapped)|
      key = new_key if id == wid
      new_state.push [id, name, key, mapped]
    end
    update_config new_state
  end

  def self.grab_window
    wid = `xdotool selectwindow`.to_i
    new_key = ask_for_key
    new_name = `xdotool getwindowname #{wid}`
    new_state = []
    updated = false
    hotkeys.each do |(id, name, key, mapped)|
      if id == wid
        updated = true
        key = new_key
      end
      new_state.push [id, name, key, mapped]
    end
    new_state.push [wid, new_name, new_key, true] unless updated
    update_config new_state
  end

  def self.ask_for_key
    `xbindkeys -k`.split("\n").last
  end
end

