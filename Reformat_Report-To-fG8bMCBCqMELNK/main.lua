-- This example shows how we can achieve a maximum of N characters per line. 
-- The goal is to split text into lines of equal length to make it easier to
-- display in a downstream system.

-- http://help.interfaceware.com/v6/reformat-report

-- It's a good idea to expand out the reports before and after to see them.

-- notice how we use require add the function to the "string" global namespace
string.formatText = require 'string.formatText'

local MAXLENGTH = 80   -- the maximum length, in characters

function main(Before)

   -- count and display the number of lines in the initial report
   local FirstReport = Before:split('\r')          -- split report and
   trace("We start with "..#FirstReport.." lines") -- show line count
   
   -- split the report into a table of smaller lines of 
   -- whole words with each line no longer than MAXLENGTH
   local SplitTextArray = Before:formatText(MAXLENGTH)

   -- concatenate the table with smaller lines into a single string
   -- using a separator of "\n"
   local After = table.concat(SplitTextArray, "\n")

   -- display count of lines for the reformatted report
   trace("And end with "..#SplitTextArray.." lines of shorter length.")   
end