-- require imports a shared module into the project (See Project Manager on left)
-- http://help.interfaceware.com/v6/retry-example

local RandomMessage = require 'ran'

-- This translator instance is generating random HL7 messages to test out the
-- the retry module.

-- This is a very rough example showing how we can generate random HL7
-- data using the translator.  
      
function main()
   -- Push the ADT message through to destination
   -- Press 'RandomMessage' on right to navigate
   -- through code
   queue.push{data=RandomMessage()}
end

