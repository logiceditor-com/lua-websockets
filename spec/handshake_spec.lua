require'busted'
package.path = package.path..'../src'

local handshake = require'websocket.handshake'
local socket = require'socket'
require'pack'

local request_lines = {
   'GET /chat HTTP/1.1',
   'Host: server.example.com',
   'Upgrade: websocket',
   'Connection: Upgrade',
   'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==',
   'Sec-WebSocket-Protocol: chat, superchat',
   'Sec-WebSocket-Version: 13',
   'Origin: http://example.com',
   '\r\n'
}
local request_header = table.concat(request_lines,'\r\n')

describe(
   'The handshake module',
   function()
      it(
	 'RFC 1.3: calculate the correct accept sum',
	 function()
	    local sec_websocket_key = "dGhlIHNhbXBsZSBub25jZQ=="
	    local accept = handshake.sec_websocket_accept(sec_websocket_key)
	    assert.is_same(accept,"s3pPLMBiTxaQ9kYGzzhZRbK+xOo=")
	 end)

      it(
	 'can create handshake header',
	 function()
            local req = handshake.upgrade_request
            {
               key = 'dGhlIHNhbXBsZSBub25jZQ==',
               host = 'server.example.com',
               origin = 'http://example.com',
               protocols = {'chat','superchat'},
               uri = '/chat'
            }
            assert.is_same(req,request_header)
	 end)

      it(
	 'can parse handshake header',
	 function()
            local headers,remainder = handshake.http_headers(request_header..'foo')
            assert.is_same(type(headers),'table')
            assert.is_same(headers['upgrade'],'websocket')
            assert.is_same(headers['connection'],'upgrade')
            assert.is_same(headers['sec-websocket-key'],'dGhlIHNhbXBsZSBub25jZQ==')
            assert.is_same(headers['sec-websocket-version'],'13')
            assert.is_same(headers['sec-websocket-protocol'],'chat, superchat')
            assert.is_same(headers['origin'],'http://example.com')
            assert.is_same(headers['host'],'server.example.com')
            assert.is_same(remainder,'foo')
	 end)

      it(
	 'generates correct upgrade response',
	 function()
            local response,protocol = handshake.accept_upgrade(request_header,{'chat'})
            assert.is_same(type(response),'string')
            assert.is_truthy(response:match('^HTTP/1.1 101 Switching Protocols\r\n'))
            assert.is_same(protocol,'chat')
            local headers = handshake.http_headers(response)
            assert.is_same(type(headers),'table')
            assert.is_same(headers['upgrade'],'websocket')
            assert.is_same(headers['connection'],'upgrade')
            assert.is_same(headers['sec-websocket-accept'],'s3pPLMBiTxaQ9kYGzzhZRbK+xOo=')
	 end)

      it(
         'can connect and upgrade node websocket on port 8080',
         function()
            local sock = socket.tcp()
            sock:settimeout(0.3)
            sock:connect('localhost',8080)
            local req = handshake.upgrade_request
            {
               key = 'dGhlIHNhbXBsZSBub25jZQ==',
               host = 'localhost',
               protocols = {'echo-protocol'},
               origin = 'http://example.com',
               uri = '/'
            }
            sock:send(req)
            local resp = {}            
            repeat 
               local line,err = sock:receive('*l')               
               resp[#resp+1] = line
            until err or line == ''
            assert.is_falsy(err)
            local response = table.concat(resp,'\r\n')
            assert.is_truthy(response:match('^HTTP/1.1 101 Switching Protocols\r\n'))

            local headers = handshake.http_headers(response)
            assert.is_same(type(headers),'table')
            assert.is_same(headers['upgrade'],'websocket')
            assert.is_same(headers['connection'],'upgrade')
            assert.is_same(headers['sec-websocket-accept'],'s3pPLMBiTxaQ9kYGzzhZRbK+xOo=')
            assert.is_truthy(headers['sec-websocket-protocol']:match('echo%-protocol'))          
         end)
   end)