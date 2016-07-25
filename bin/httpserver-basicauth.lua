-- httpserver-basicauth.lua
-- Part of nodemcu-httpserver, authenticates a user using http basic auth.
-- Author: Sam Dieck

basicAuth = {}

-- Parse basic auth http header.
-- Returns the username if header contains valid credentials,
-- nil otherwise.
function basicAuth.authenticate(header)
   local credentials_enc = header:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
   if not credentials_enc then
      return nil
   end
   local credentials = encoder.fromBase64(credentials_enc)
   local user, pwd = credentials:match("^(.*):(.*)$")
   if user ~= conf.auth.user or pwd ~= conf.auth.password then
      print("httpserver-basicauth: User \"" .. user .. "\": Access denied.")
      return nil
   end
   print("httpserver-basicauth: User \"" .. user .. "\": Authenticated.")
   return user
end

function basicAuth.authErrorHeader()
   return "WWW-Authenticate: Basic realm=\"" .. conf.auth.realm .. "\""
end

return basicAuth
