return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   if req.method == 'POST' then
      --print('POST method')
      local rd = req.getRequestData()
      --print(node.heap())
      collectgarbage()
      --print(node.heap())
      if rd['action'] == 'list' then
         print('retrieve file list')
         local l, filelist, n, s, ok, json
         l = file.list()
         filelist = {}
         for n, s in pairs(l) do
            if ((string.sub(n, -3) ~= '.gz') and (string.sub(n, -3) ~= '.lc')) then
               filelist[n] = s
            end
         end
         ok, json = pcall(cjson.encode, filelist)
         if ok then
            --print(json)
            connection:send(json)
         else
            --print("failed to encode!")
         end
      elseif rd['action'] == 'load' then
         print('load file: '..rd['filename'])
         file.open(rd['filename'], 'r')
         local buffer = file.read()
         while buffer ~= nil do
            connection:send(buffer)
            buffer = file.read()
         end
         file.close()
      elseif rd['action'] == 'save' then
         print('save file: '..rd['filename'])
         local data = rd['data']
         file.open(rd['filename'], 'w+')
         file.write(data)
         file.close()
         connection:send('initial write: ' .. string.len(data))
      elseif rd['action'] == 'append' then
         print('append file: '..rd['filename'])
         local data = rd['data']
         file.open(rd['filename'], 'a+')
         file.seek('end')
         file.write(data)
         file.close()
         connection:send('append: ' .. string.len(data))
      elseif rd['action'] == 'compile' then
         print('compile file: '..rd['filename'])
         node.compile(rd['filename'])
      end
   end
   collectgarbage()
end
