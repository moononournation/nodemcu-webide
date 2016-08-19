return function (socket)
  function socket.onmessage(payload, opcode)
    ws2812.write(payload)
  end
end
