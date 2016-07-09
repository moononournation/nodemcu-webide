return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   if req.method == 'POST' then
      local rd = req.getRequestData()
      if (rd['data'] ~= nil) then
         ws2812.write(rd['data'])
      end
   end
   collectgarbage()
end
