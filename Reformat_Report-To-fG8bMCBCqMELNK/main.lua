-- This example shows how we can achieve a maximum of N characters per line. 
-- The goal is to split text into lines of equal length to make it easier to
-- display in a downstream system.

-- It's a good idea to expand out the reports before and after to see them.

string.formatText = require 'string.formatText'

function main(Before)
   local FirstReport = Before:split("\r")
   trace("We start with "..#FirstReport.." lines")
   local MAXLENGTH = 80 -- the maximum length, in characters
   local SplitTextArray = Before:formatText(MAXLENGTH, SplitTextArray)
   trace(SplitTextArray)
   local After = table.concat(SplitTextArray, "\n")
   trace(After)
   trace("And end with "..#SplitTextArray.." lines of shorter length.")   
end


