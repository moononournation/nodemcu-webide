return function (connection, req, args)
  dofile('httpserver-header.lc')(connection, 200, 'html')

  --define robot dance steps
  --F=move forward, B=move backward, L=turn left, R=turn right, S=stop
  local steps = 'FFSSFFRSRFFSFFSSBBSSBBSSBBSSBBSSFFSSFFSSFFSSFFLSLBBS' --Tango
  local curStepIdx = 1

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

  --run step every tmrMs
  tmr.alarm(tmrId, tmrMs, tmr.ALARM_SEMI, function()
    local curStep = string.sub(steps, curStepIdx, curStepIdx)
    if ((curStep ~= nil) and (curStep ~= '')) then
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
      curStepIdx = curStepIdx + 1
      tmr.start(tmrId)
    else
      pwm.stop(leftpwm)
      gpio.write(leftpin1, gpio.LOW)
      gpio.write(leftpin2, gpio.LOW)
      pwm.stop(rightpwm)
      gpio.write(rightpin1, gpio.LOW)
      gpio.write(rightpin2, gpio.LOW)
      tmr.unregister(tmrId)
    end
  end)

  connection:send([===[<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>robot.lua</title>
  </head>
  <body>
    <h1>Running!</h1>
  </body>
</html>]===])
end
