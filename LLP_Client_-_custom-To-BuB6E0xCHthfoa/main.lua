-- The LLP client allows one to make LLP connections from the translator in Lua
-- See http://help.interfaceware.com/code/details/llp-lua

local llp = require 'llp'

function main(Data)
   local s = llp.connect{host='localhost',port=7013}
   s:send(Data)
   local Ack = s:recv()
   trace(Ack)
   s:close()
   util.sleep(50)
end