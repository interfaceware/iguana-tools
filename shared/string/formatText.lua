-- This module splits text into lines of equal length 
-- often used to make a report easier to display in a downstream system.

-- http://help.interfaceware.com/v6/reformat-report

local function formatText(s, M)
   local function lengthofWord(word)
      if word == '\n' or word == '\r' or word == '\t' then return #word + 1 end
      return #word
   end
   local function RSindex(RS, i)
      if (#tostring(RS[i])) > (M - countOfWord - 2) then return i+1  end    
      return i
   end
   local i, position = 1, 0
   local RS = {[1]=''} 
   for word in s:rxmatch('(\\w+.|\\s)') do
      countOfWord = lengthofWord(word)
      i = RSindex(RS, i) 
      if RS[i] == nil then RS[i] = '' end
      RS[i] = RS[i]..word 
   end
   return RS
end

local Help = {
   Title="string.formatText",
   Usage="string.formatText(text, maxlength)",
   Desc=[[Breaks a block of text into several smaller lines each ending in a whole word, 
with a maximum length of the maxlength parameter.<br><br><b>Note:</b> The block of text 
may contain multiple lines.]],
   ParameterTable=false,
   Parameters={
      {text={Desc="Block of text to be formatted <u>string</u>."}},
      {maxlength={Desc="Maximum line length allowed <u>integer</u>."}}
   },
   Returns={
      {Desc="One or more lines of text as specified <u>table</u>."}
   },
   Examples={[[-- reformat "Report" into shorter lines 
local MAXLENGTH = 80
local SplitTextArray = Report:formatText(MAXLENGTH)]]},
   SeeAlso={
      {
         Title="Reformat Report",
         Link="http://help.interfaceware.com/v6/reformat-report"
      },
      {
         Title="Source code for the string.formatText.lua module on github",
         Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/string/formatText.lua"
      }
   },
}

help.set{input_function=formatText, help_data=Help}

return formatText

