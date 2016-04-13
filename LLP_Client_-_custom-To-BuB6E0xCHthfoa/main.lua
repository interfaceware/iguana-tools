-- The LLP client allows one to make LLP connections from the translator in Lua

-- http://help.interfaceware.com/v6/llp-client-custom

local llp = require 'llp'

function main(Data)
   local s = llp.connect{host='localhost',port=7013}
   s:send(Data)
   local Ack = s:recv()
   trace(Ack)
   s:close()
   util.sleep(50)
end