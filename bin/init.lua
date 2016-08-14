-- init adc
if adc.force_init_mode(adc.INIT_VDD33) then
  node.restart()
end

-- init and clear ws2812
ws2812.init()
ws2812.write(string.char(0):rep(3096))

-- init config
dofile('config.lua')

-- init WiFi
-- Tell the chip to connect to the access point
wifi.setmode(conf.wifi.mode)
print('set (mode='..wifi.getmode()..')')

if (conf.wifi.mode == wifi.SOFTAP) or (conf.wifi.mode == wifi.STATIONAP) then
    print('AP MAC: ', wifi.ap.getmac())
    wifi.ap.config(conf.wifi.ap)
    wifi.ap.setip(conf.wifi.apip)
end
if (conf.wifi.mode == wifi.STATION) or (conf.wifi.mode == wifi.STATIONAP) then
    print('Client MAC: ', wifi.sta.getmac())
    wifi.sta.sethostname(conf.wifi.stahostname)
    wifi.sta.config(conf.wifi.stassid, conf.wifi.stapwd, 1)
end

conf.wifi = nil
collectgarbage()

-- show system info
print('chip: ',node.chipid())
print('heap: ',node.heap())

-- Compile server code and remove original .lua files.
-- This only happens the first time afer the .lua files are uploaded.
local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local serverFiles = {
   'httpserver.lua',
   'httpserver-basicauth.lua',
   'httpserver-connection.lua',
   'httpserver-error.lua',
   'httpserver-header.lua',
   'httpserver-request.lua',
   'httpserver-static.lua',
   'file-api.lua'
}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
i = nil
f = nil
collectgarbage()

-- pre-compile other lua files
local l, f, s
l = file.list();
for f, s in pairs(l) do
  if ((string.sub(f, -4) == '.lua') and (f ~= 'config.lua') and (f ~= 'init.lua')) then
    print('Pre-compiling:', f)
    node.compile(f)
    collectgarbage()
  end
end
l = nil
f = nil
s = nil
collectgarbage()

-- check and show STATION mode obtained IP
if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then
    local joinCounter = 0
    local joinMaxAttempts = 5
    tmr.alarm(0, 3000, 1, function()
       local ip = wifi.sta.getip()
       if ip == nil and joinCounter < joinMaxAttempts then
          print('Connecting to WiFi Access Point ...')
          joinCounter = joinCounter +1
       else
          if joinCounter == joinMaxAttempts then
             print('Failed to connect to WiFi Access Point.')
          else
             print('IP: ',ip)
             mdns.register(conf.wifi.stahostname, { description="NodeMCU WebIDE", service="http", port=80, location='In your ESP board' })
          end
          tmr.stop(0)
          joinCounter = nil
          joinMaxAttempts = nil
          collectgarbage()
       end
    end)
end

-- start the nodemcu-httpserver in port 80
if (not not wifi.sta.getip()) or (not not wifi.ap.getip()) then
    dofile("httpserver.lc")(80)
    collectgarbage()
end
