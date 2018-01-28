# **NodeMCU WebIDE** #

![Prototype](https://cdn.instructables.com/FEK/5NJY/IRLQGMKS/FEK5NJYIRLQGMKS.RECTANGLE1.jpg)

You may find more details at my instructables:
http://www.instructables.com/id/NodeMCU-WebIDE/

## NodeMCU WebIDE base on 2 core projects:
### [nodemcu-httpserver](https://github.com/marcoskirsch/nodemcu-httpserver)
A (very) simple web server written in Lua for the ESP8266 running the NodeMCU firmware.

### [CodeMirror](https://codemirror.net)
A versatile text editor implemented in JavaScript for the browser.

##nodemcu-websocket.lua rewrite from:
### [creationix/nodemcu-webide](https://github.com/creationix/nodemcu-webide)
A websocket based IDE for nodemcu devices.

##Todo
- allow multiple opened files
- auto save file in web browser local storage
- redirect NodeMCU output to web browser
- new file template
- more editor basic feature, such as search
- refresh button for reload file list
- fix WebSocket memory leakage issue
- utilize WebSocket in WebIDE