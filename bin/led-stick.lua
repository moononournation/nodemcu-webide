return function (connection, req, args)
  local pin, w, h, offset = 1, 140, 28, 0

  if connection ~= nil then
    dofile('httpserver-header.lc')(connection, 200, 'html')
  end

  gpio.mode(pin, gpio.INT)
  local function pin1cb(level)
    print(level)
    file.open('led-stick.dat', 'r')
	if level == 1 then
	  offset = 0
      while offset < w do
        file.seek("set", (offset * h) * 3)
        ws2812.write(file.read(h * 3))
        offset = offset + 1
      end
    else
      offset = w - 1
      while offset >= 0 do
        file.seek("set", (offset * h) * 3)
        ws2812.write(file.read(h * 3))
        offset = offset - 1
      end
	end
    file.close()
    ws2812.write(string.char(0):rep(h * 3))
  end
  gpio.trig(pin, 'both', pin1cb)
end
