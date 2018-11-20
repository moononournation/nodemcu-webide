return function (connection, req, args)
  local size, frame, offset, tmrId, tmrMs = 25, 6, 0, 4, 200

  if connection ~= nil then
    dofile('httpserver-header.lc')(connection, 200, 'html')
  end

  tmr.alarm(tmrId, tmrMs, tmr.ALARM_SEMI, function()
    if file.open('led-sign.dat', 'r') then
      file.seek("set", (offset * size) * 3)
      ws2812.write(file.read(size * 3))
      file.close()
      offset = offset + 1
      if offset >= frame then
        offset = 0
      end
      tmr.start(tmrId)
    end
  end)
end
