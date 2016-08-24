--rewrite from https://github.com/creationix/nodemcu-webide

local function decode(chunk)
  if #chunk < 2 then return end
  local second = string.byte(chunk, 2)
  local len = bit.band(second, 0x7f)
  local offset
  if len == 126 then
    if #chunk < 4 then return end
    len = bit.bor(
      bit.lshift(string.byte(chunk, 3), 8),
      string.byte(chunk, 4))
    offset = 4
  elseif len == 127 then
    if #chunk < 10 then return end
    len = bit.bor(
      -- Ignore lengths longer than 32bit
      bit.lshift(string.byte(chunk, 7), 24),
      bit.lshift(string.byte(chunk, 8), 16),
      bit.lshift(string.byte(chunk, 9), 8),
      string.byte(chunk, 10))
    offset = 10
  else
    offset = 2
  end
  local mask = bit.band(second, 0x80) > 0
  if mask then
    offset = offset + 4
  end
  if #chunk < offset + len then return end

  local first = string.byte(chunk, 1)
  local payload = string.sub(chunk, offset + 1, offset + len)
  assert(#payload == len, "Length mismatch")
  if mask then
    payload = crypto.mask(payload, string.sub(chunk, offset - 3, offset))
  end
  local extra = string.sub(chunk, offset + len + 1)
  local opcode = bit.band(first, 0xf)
  return extra, payload, opcode
end

local function encode(payload, opcode)
  opcode = opcode or 2
  assert(type(opcode) == "number", "opcode must be number")
  assert(type(payload) == "string", "payload must be string")
  local len = #payload
  local head = string.char(
    bit.bor(0x80, opcode),
    bit.bor(len < 126 and len or len < 0x10000 and 126 or 127)
  )
  if len >= 0x10000 then
    head = head .. string.char(
    0,0,0,0, -- 32 bit length is plenty, assume zero for rest
    bit.band(bit.rshift(len, 24), 0xff),
    bit.band(bit.rshift(len, 16), 0xff),
    bit.band(bit.rshift(len, 8), 0xff),
    bit.band(len, 0xff)
  )
  elseif len >= 126 then
    head = head .. string.char(bit.band(bit.rshift(len, 8), 0xff), bit.band(len, 0xff))
  end
  return head .. payload
end

local guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
local function acceptKey(key)
  return crypto.toBase64(crypto.hash("sha1", key .. guid))
end

return function (connection, payload)
  local buffer = false
  local socket = {}
  local queue = {}
  local waiting = false
  local function onSend()
    if queue[1] then
      local data = table.remove(queue, 1)
      return connection:send(data, onSend)
    end
    waiting = false
  end
  function socket.send(...)
    local data = encode(...)
    if not waiting then
      waiting = true
      connection:send(data, onSend)
    else
      queue[#queue + 1] = data
    end
    collectgarbage()
    print(node.heap())
  end

  connection:on("receive", function(_, chunk)
    if buffer then
      buffer = buffer .. chunk
      while true do
        local extra, payload, opcode = decode(buffer)
        if not extra then return end
        buffer = extra
        socket.onmessage(payload, opcode)
      end
    end
  end)

  connection:on("sent", function(_, _)
    if socket.onsent ~= nil then
      socket.onsent()
    end
  end)

  connection:on("disconnection", function(_, _)
    if socket.onclose ~= nil then
      socket.onclose()
    end
  end)

  local req = dofile("httpserver-request.lc")(payload)
  local key = payload:match("Sec%-WebSocket%-Key: ([A-Za-z0-9+/=]+)")
  local fileExists = file.open(req.uri.file, "r")
  file.close()
  if req.method == "GET" and key and fileExists then
    connection:send(
      "HTTP/1.1 101 Switching Protocols\r\n" ..
      "Upgrade: websocket\r\nConnection: Upgrade\r\n" ..
      "Sec-WebSocket-Accept: " .. acceptKey(key) .. "\r\n\r\n",
      function () dofile(req.uri.file)(socket) end)
    buffer = ""
  else
    connection:send(
      "HTTP/1.1 404 Not Found\r\nConnection: Close\r\n\r\n",
      connection.close)
  end
end
