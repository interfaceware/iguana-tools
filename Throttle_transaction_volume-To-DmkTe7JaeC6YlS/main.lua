-- This example shows the use of the throttle module to limit the speed of transactions during core hours
-- This could be useful if you are running a data center that has multiple customers feeding into it 
-- i.e. a 'multi-tenant' architecture in jargon speak.
-- If you have one client that is flooding the centre with too much data then you might want to throttle the
-- the traffic from that client to stop their feed from hogging resources from the rest of the customers.
-- See http://help.interfaceware.com/v6/throttle

local throttle = require 'throttle'

function main(Data)
   throttle.run(ExpensiveOperation, Data)
end

function ExpensiveOperation(Data)
      
end