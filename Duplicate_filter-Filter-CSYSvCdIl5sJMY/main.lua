dup = require 'dup'
-- This shows the usage of the duplicate filter
-- See http://help.interfaceware.com/code/details/dup-lua

function main(Data)
   iguana.logInfo("Duplicate filter received message!")
   -- lookback_amount is the amount of previous messages to look back 
   -- through the logs for a duplicate.
   local Success = dup.isDuplicate{data=Data, lookback_amount=800}
  
   if Success then
      iguana.logInfo('Found a Duplicate!')
      return    
   end
   -- If it's not a duplicate then push the message into the queue
   queue.push{data=Data}
end

