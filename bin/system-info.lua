return function (connection, req, args)
  dofile('httpserver-header.lc')(connection, 200, 'html')

  connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>WiFi info</title></head><body>')

  connection:send('<p><b>Chip ID:</b> '..node.chipid()..'</p>')
  connection:send('<p><b>Flash ID:</b> '..node.flashid()..'</p>')
  connection:send('<p><b>Heap:</b> '..node.heap()..'</p>')
  connection:send('<p><b>Info:</b> '..node.info()..'</p>')

  connection:send('<p><b>Vdd:</b> '..adc.readvdd33()..' mV</p>')

  local address, size = file.fscfg()
  connection:send('<p><b>File System Address:</b> '..address..'</p>')
  connection:send('<p><b>File System Size:</b> '..size..' bytes</p>')

  local remaining, used, total = file.fsinfo()
  connection:send('<p><b>File System Usage:</b> '..used..' / '..total..' bytes</p>')
  connection:send('<p><b>Wifi MAC Address:</b> '..wifi.sta.getmac()..'</p>')

  connection:send('<p><b>WiFi Channel:</b> '..wifi.getchannel()..'</p>')

  local wifimode = wifi.getmode()
  if wifimode == wifi.STATION then
    connection:send('<p><b>WiFi Mode:</b> STATION</p>')
  elseif wifimode == wifi.SOFTAP then
    connection:send('<p><b>WiFi Mode:</b> SOFTAP</p>')
  elseif wifimode == wifi.STATIONAP then
    connection:send('<p><b>WiFi Mode:</b> STATIONAP</p>')
  elseif wifimode == wifi.NULLMODE then
    connection:send('<p><b>WiFi Mode:</b> NULLMODE</p>')
  end

  local wifiphymode = wifi.getphymode()
  if wifiphymode == wifi.PHYMODE_B then
    connection:send('<p><b>WiFi Physical Mode:</b> B</p>')
  elseif wifiphymode == wifi.PHYMODE_G then
    connection:send('<p><b>WiFi Physical Mode:</b> G</p>')
  elseif wifiphymode == wifi.PHYMODE_N then
    connection:send('<p><b>WiFi Physical Mode:</b> N</p>')
  end

  local status = wifi.sta.status()
  if status == 0 then
    connection:send('<p><b>wifi.sta.status:</b> STA_IDLE</p>')
  elseif status == 1 then
    connection:send('<p><b>wifi.sta.status:</b> STA_CONNECTING</p>')
  elseif status == 2 then
    connection:send('<p><b>wifi.sta.status:</b> STA_WRONGPWD</p>')
  elseif status == 3 then
    connection:send('<p><b>wifi.sta.status:</b> STA_APNOTFOUND</p>')
  elseif status == 4 then
    connection:send('<p><b>wifi.sta.status:</b> STA_FAIL</p>')
  elseif status == 5 then
    connection:send('<p><b>wifi.sta.status:</b> STA_GOTIP</p>')
    connection:send('<p><b>IP:</b> '..wifi.sta.getip())
    connection:send('<p><b>RSSI:</b> '..wifi.sta.getrssi()..' dB</p>')
  end
  connection:send('</body></html>')
end
