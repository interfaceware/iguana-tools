-- The LLP client allows one to make LLP connections from the translator in Lua

-- http://help.interfaceware.com/v6/llp-client-custom

local llp = {}
llp.connect = require 'llp'

function main(Data)
   -- use llp.connect to the LLP connection
   local s = llp.connect{host='localhost',port=7013}
   
   -- use s:send() and s:rev() to send and receive messages
   s:send(Data)
   local Ack = s:recv()
   trace(Ack)
   
   -- use s:close() to close the connection
   -- it is usually best practise to close connections
   -- (unless you really want multiple connections)
   -- Many hosts will actually reject multiple connections, 
   -- and most will become overwhelmed if you make too many
   s:close()
   util.sleep(50)
end