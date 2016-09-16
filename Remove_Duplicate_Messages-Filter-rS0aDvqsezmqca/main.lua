-- This shows the usage of the duplicate filter
-- See http://help.interfaceware.com/v6/duplicate-filter

local dup = require 'dup'

-- To tell if a message is trully a duplicate
-- it helps to pass each message through a function
-- which removes a trivial detail.
local function StripMSHTime(Data)
   local SegmentList = Data:split("\r")
   local MshField = SegmentList[1]:split("|")
   MshField[7] = ""
   SegmentList[1] = table.concat(MshField, "|")
   local HL7out = table.concat(SegmentList, "\r")
   return HL7out
end

function main(Data)
   iguana.logInfo("Duplicate filter received message!")
   -- lookback_amount is the amount of previous messages to look back 
   -- through the logs for a duplicate.
   
   -- The transform function is an optional function which can be used to "normalise" messages
   -- that are really duplicates but might have trivial differences like the timestamp in the
   -- MSH field.
   local Success = dup.isDuplicate{data=Data, lookback_amount=800, transform=StripMSHTime}
  
   if Success then
      iguana.logInfo('Found a Duplicate!')
      return    
   end
   -- If it's not a duplicate then push the message into the queue
   queue.push{data=Data}
end   