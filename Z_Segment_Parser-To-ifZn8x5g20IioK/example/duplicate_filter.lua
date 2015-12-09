-- This module shows a really handy utility for filtering duplicate HL7 messages
-- It does it efficiently using MD5 hashes in memory buffer.

-- We import the module with the 'dup' name here
dup = require 'dup'

function FilterDuplicates(Data)
   dup.isDuplicate{data=Data, lookback_amount=800}
end