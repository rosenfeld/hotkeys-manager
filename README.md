# Global Hotkeys Manager

Global hotkeys management for Linux/X11 environments.

## About

I like to toggle the visibility of some common apps through global shortcuts/hotkeys, like the
browser, terminal emulator, code editor, instant message client and so on. Too much open windows
in my desktop feel like a mess to me and it's hard to switch among many of them by using Alt+Tab.

Tools like kdocker allow us to send any window to the tray, but I wasn't able to find any tool
that would allow me to assign the windows some shortcuts so that I wouldn't need the mouse to
switch among them. I created [Ktrayshortcut](https://github.com/rosenfeld/ktrayshortcut) a while
back to allow me to assign global hotkeys in addition to sending them to the tray. But after KDE
moved from version 4 to KF5 lots of API changes made it hard to update the source-code as many
things got much more complicated. I wasn't comfortable with having to spend too much time updating
the source code everytime the API changed so today I was experimenting with some command line
tools and decided to take another approach using tools I'm comfortable with, like Ruby, web
development and command line tools.

So, after a few hours I was able to put the pieces together and create a simple Sinatra web
application with little of Ruby and plain JavaScript to get what I need done. After using
Ktrayshorcut for a long time I realized I didn't really need any tray icons, just the hotkeys to
toggle the applications, so this program does just that. It's simple to create and simple to
maintain as long the required tools don't change too much.

I thought about using Shoes to create the UI but I didn't like to add another big dependency
(Java) and I'm not aware of any other GUI tool supporting Ruby that is lightweight, well
documented and easy to use, so I decided to create a web app since I'm comfortable with maintaining
them.

## Requirements

- xdotool
- xbindkeys
- xwininfo (from x11-utils package)
- Ruby

## Install

    sudo apt-get install xdotool x11-utils xbindkeys ruby
    gem install global_hotkeys_manager

## Usage

    global_hotkeys_manager (simply start the daemon at port 4242)

To change the port simply set the `HOTKEYS_MANAGER_PORT` environment variable:

    HOTKEYS_MANAGER_PORT=4444 global_hotkeys_manager

Other commands:

    global_hotkeys_manager help
    global_hotkeys_manager status
    global_hotkeys_manager stop
    global_hotkeys_manager toggle window_id (used internally)
    global_hotkeys_manager debug (like start but not in daemon mode)

Access the UI through http://127.0.0.1:4242

I also found useful to assign a global shortcut for accessing this address in Chrome any time I
want to add a new window. Just add something like this to your ~/.xbindkeysrc:

"google-chrome --app=http://127.0.0.1:4242 && sleep 0.2 && xdotool search "Global Hotkeys Manager" windowactivate "
    m:0x19 + c:58
    Shift+Alt+Mod2 + m

All hotkeys managed by this application uses a separate configuration file rather than
~/.xbindkeysrc (~/.config/global-hotkeys-manager/xbindkeysrc).
