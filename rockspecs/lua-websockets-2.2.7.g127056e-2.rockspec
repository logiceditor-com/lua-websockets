package = "lua-websockets"
version = "2.2.7.g127056e-2"

source = {
  url = "git+https://github.com/logiceditor-com/lua-websockets.git",
  branch = "v2.2.7.g127056e"
}

description = {
  summary = "Websockets for Lua",
  homepage = "http://github.com/lipp/lua-websockets",
  license = "MIT/X11",
  detailed = "Provides sync and async clients and servers for copas and lua-ev."
}

dependencies = {
  "lua >= 5.1",
  "luasocket",
  "bitop-lua"
}

build = {
  type = 'none',
  install = {
    lua = {
      ['websocket'] = 'src/websocket.lua',
      ['websocket.sync'] = 'src/websocket/sync.lua',
      ['websocket.client'] = 'src/websocket/client.lua',
      ['websocket.client_sync'] = 'src/websocket/client_sync.lua',
      ['websocket.client_poller'] = 'src/websocket/client_poller.lua',
      ['websocket.poller'] = 'src/websocket/poller.lua',
      ['websocket.server'] = 'src/websocket/server.lua',
      ['websocket.handshake'] = 'src/websocket/handshake.lua',
      ['websocket.tools'] = 'src/websocket/tools.lua',
      ['websocket.frame'] = 'src/websocket/frame.lua',
      ['websocket.bit'] = 'src/websocket/bit.lua',
    }
  }
}
