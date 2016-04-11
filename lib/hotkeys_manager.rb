require 'json'

class HotkeysManager
  CONFIG_DIR = File.expand_path '../config', __dir__
  XBINDKEYSRC = "#{CONFIG_DIR}/xbindkeysrc"
  HOTKEYS_JSON = "#{CONFIG_DIR}/hotkeys.json"
  PORT = 4242
  URL_BASE = "http://localhost:#{PORT}"

  def self.pid
    return unless pid = `pgrep -o -f xbindkeys.*hotkeys`.split("\n").find{|p| system "kill -0 #{p}"}
    system("kill -0 #{pid}") and pid.to_i
  end

  def self.ensure_running
    id = pid and `kill #{id}`
    `xbindkeys -f #{XBINDKEYSRC}`
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
    newstate = []
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
      newstate.push [id, name, key, mapped]
    end
    update_config newstate
  end

  def self.update_config(hotkeys)
    hotkeys = hotkeys.find_all{|(id, name, key, mapped)| valid_window_id? id}
    File.write HOTKEYS_JSON, JSON.unparse(hotkeys)
    File.write XBINDKEYSRC, hotkeys.map{|(id, name, key, mapped)|
      %Q{\##{name}\n"curl -X POST #{URL_BASE}/toggle/#{id}"\n#{key}\n}
    }.join("\n\n")
    ensure_running
  end

  def self.update_name(wid, new_name)
    newstate = []
    hotkeys.each do |(id, name, key, mapped)|
      name = new_name if id == wid
      newstate.push [id, name, key, mapped]
    end
    update_config newstate
  end

  def self.update_key(wid)
    newkey = ask_for_key
    newstate = []
    hotkeys.each do |(id, name, key, mapped)|
      key = newkey if id == wid
      newstate.push [id, name, key, mapped]
    end
    update_config newstate
  end

  def self.grab_window
    id = `xdotool selectwindow`.to_i
    newkey = ask_for_key
    name = `xdotool getwindowname #{id}`
    update_config(hotkeys + [[id, name, newkey, true]])
  end

  def self.ask_for_key
    `xbindkeys -k`.split("\n").last
  end
end
