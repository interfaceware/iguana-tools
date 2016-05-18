-- Sometimes you need to remove unprintable characters that have a 
-- an ascii value of 128 or above. This module does this.

-- http://help.interfaceware.com/v6/strip-unprintable-characters 

-- strip out unprintable characters = \128 to \255
local function Strip(string)
   return string:gsub("[\128-\255]", "")
end

local Help = {
   Title="bin.strip",
   Usage="bin.strip(string)",
   ParameterTable=false,
   Parameters={
      {string={Desc="String of text to strip unprintable characters from <u>string</u>."}}
   },

   Returns={
      {Desc="String of text with unprintable characters removed <u>string</u>.."}
   },
   Examples={[[-- strip any unprintable characters
local GoodString = bin.strip(BadString)]]},
   Desc="Creates an empty database schema table, with various functions for working with databases, creating a DBS file, etc.",
   SeeAlso={
      {
         Title="Strip Unprintable Characters",
         Link="http://help.interfaceware.com/v6/strip-unprintable-characters"
      },
      {
         Title="Source code for the bin.strip.lua module on github",
         Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/bin/strip.lua"
      }
   },
}

help.set{input_function=Strip, help_data=Help}

return Strip