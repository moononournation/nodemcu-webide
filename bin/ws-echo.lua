return function (socket)
  function socket.onmessage(payload, opcode)
    socket.send(payload, opcode)
  end
end
