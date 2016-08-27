return function (socket)
  --1=GPIO5, 2=GPIO4, 3=GPIO0, 4=GPIO2, 5=GPIO14, 6=GPIO12,
  --7=GPIO13, 8=GPIO15, 9=GPIO3, 10=GPIO1, 11=GPIO9, 12=GPIO10
  local leftpwm, leftduty, leftpin1, leftpin2 = 1, 818, 2, 4 --GPIO5, 80%, GPIO4, GPIO2
  local rightpwm,rightduty, rightpin1, rightpin2 = 5, 717, 6, 7 --GPIO14, 70%, GPIO12, GPIO13
  -- timer id(0-6), interval in ms
  local tmrId, tmrMs = 4, 800

  -- init motors
  pwm.setup(leftpwm, 500, leftduty)
  pwm.start(leftpwm)
  gpio.mode(leftpin1, gpio.OUTPUT)
  gpio.mode(leftpin2, gpio.OUTPUT)
  pwm.setup(rightpwm, 500, rightduty)
  pwm.start(rightpwm)
  gpio.mode(rightpin1, gpio.OUTPUT)
  gpio.mode(rightpin2, gpio.OUTPUT)

  function socket.onmessage(payload, opcode)
    curStep = payload:sub(1, 1)
    if (curStep == 'F') then
      gpio.write(leftpin1, gpio.LOW)
      gpio.write(leftpin2, gpio.HIGH)
      gpio.write(rightpin1, gpio.LOW)
      gpio.write(rightpin2, gpio.HIGH)
    elseif (curStep == 'B') then
      gpio.write(leftpin1, gpio.HIGH)
      gpio.write(leftpin2, gpio.LOW)
      gpio.write(rightpin1, gpio.HIGH)
      gpio.write(rightpin2, gpio.LOW)
    elseif (curStep == 'L') then
      gpio.write(leftpin1, gpio.LOW)
      gpio.write(leftpin2, gpio.HIGH)
      gpio.write(rightpin1, gpio.HIGH)
      gpio.write(rightpin2, gpio.LOW)
    elseif (curStep == 'R') then
      gpio.write(leftpin1, gpio.HIGH)
      gpio.write(leftpin2, gpio.LOW)
      gpio.write(rightpin1, gpio.LOW)
      gpio.write(rightpin2, gpio.HIGH)
    elseif (curStep == 'S') then
      gpio.write(leftpin1, gpio.LOW)
      gpio.write(leftpin2, gpio.LOW)
      gpio.write(rightpin1, gpio.LOW)
      gpio.write(rightpin2, gpio.LOW)
    end
  end

  function socket.onclose()
    pwm.stop(leftpwm)
    gpio.write(leftpin1, gpio.LOW)
    gpio.write(leftpin2, gpio.LOW)
    pwm.stop(rightpwm)
    gpio.write(rightpin1, gpio.LOW)
    gpio.write(rightpin2, gpio.LOW)
  end
end
