-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Author: Sam Dieck

conf = {}

conf.hostname = "NODEMCU-WEBIDE" -- DNS host name send to DHCP server (don't use underscore)

-- Basic Authentication Conf
conf.auth = {}
conf.auth.enabled = true
conf.auth.realm = "nodemcu-httpserver" -- displayed in the login dialog users get
conf.auth.user = "login" -- PLEASE change this
conf.auth.password = "Passw0rd" -- PLEASE change this

-- WiFi configuration
conf.wifi = {}
-- wifi.STATION (join a WiFi network)
-- wifi.SOFTAP (create a WiFi network)
-- wifi.STATIONAP (STATION + SOFTAP)
conf.wifi.mode = wifi.SOFTAP -- default: SOFTAP (avoid try to connect an invalid AP)

-- STATION config
--conf.wifi.stassid = "YourSSID" -- Name of the WiFi network you want to join
--conf.wifi.stapwd = "PleaseInputYourPasswordHere" -- Password for the WiFi network

-- SOFTAP config
conf.wifi.ap = {}
conf.wifi.ap.ssid = "ESP-"..node.chipid() -- Name of the SSID you want to create
conf.wifi.ap.pwd = "Pass"..node.chipid() -- PLEASE change this (at least 8 characters)

conf.wifi.apip = {}
conf.wifi.apip.ip = "192.168.111.1"
conf.wifi.apip.netmask = "255.255.255.0"
conf.wifi.apip.gateway = "0.0.0.0" -- avoid mobile cannot access internet issue
