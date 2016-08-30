return function (connection, req, args)
  dofile('httpserver-header.lc')(connection, 200, 'html')

  local w, h, dataWidth, offset = 10, 6, 36, 0
  -- timer id(0-6), interval in ms
  local tmrId, tmrMs = 4, 200

  if req.method == 'POST' then
    local rd = req.getRequestData()
    if (rd['data'] ~= nil) then
      file.open('led-text.dat', 'w+')
      file.write(rd['data'])
      file.close()
    end
  end
  collectgarbage()

  tmr.alarm(tmrId, tmrMs, tmr.ALARM_SEMI, function()
    if offset < dataWidth then
      local data = ''
      file.open('led-text.dat', 'r')
      local row = 0
      while row < h do
        file.seek("set", (row * dataWidth + offset) * 3)
        local size = w
        if (offset + w > dataWidth) then
          size = dataWidth - offset
        end

        data = data .. file.read(size * 3)
        if size < w then
          data = data .. string.char(0):rep((w - size) * 3)
        end
        row = row + 1
      end
      file.close()
      ws2812.write(data)

      offset = offset + 1
      tmr.start(tmrId)
    else
      ws2812.write(string.char(0):rep(w*h*3))
      tmr.unregister(tmrId)
    end
  end)
end
