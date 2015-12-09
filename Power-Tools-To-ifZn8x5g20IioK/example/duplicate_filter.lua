-- This module shows a really handy utility for filtering duplicate HL7 messages
-- It does it efficiently using MD5 hashes in memory buffer.  For more information see
-- http://help.interfaceware.com/kb/duplicate-message-filter

-- We import the module with the 'dup' name here
dup = require 'dup'

function FilterDuplicates(Data)
   dup.isDuplicate{data=Data, lookback_amount=800}
end