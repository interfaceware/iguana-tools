-- Utility to find out if you have created new global symbols
-- http://help.interfaceware.com/v6/find-global-symbols

local Data=[[{
   "string": true,
   "iconv": true,
   "package": true,
   "tostring": true,
   "print": true,
   "_stats": true,
   "tonumber": true,
   "os": true,
   "unpack": true,
   "error": true,
   "trace": true,
   "require": true,
   "getfenv": true,
   "_VERSION": true,
   "setfenv": true,
   "setmetatable": true,
   "next": true,
   "net": true,
   "assert": true,
   "dofile": true,
   "queue": true,
   "xpcall": true,
   "io": true,
   "rawequal": true,
   "ipairs": true,
   "collectgarbage": true,
   "xml": true,
   "newproxy": true,
   "rawset": true,
   "module": true,
   "pairs": true,
   "gcinfo": true,
   "x12": true,
   "crypto": true,
   "json": true,
   "dbs": true,
   "coroutine": true,
   "load": true,
   "math": true,
   "table": true,
   "hl7": true,
   "pcall": true,
   "node": true,
   "debug": true,
   "unwind_protect": true,
   "type": true,
   "help": true,
   "select": true,
   "db": true,
   "_G": true,
   "rawget": true,
   "loadstring": true,
   "getmetatable": true,
   "main": true,
   "filter": true,
   "iguana": true,
   "chm": true,
   "util": true,
   "loadfile": true
}
]]

local function CheckForGlobals()
   if not iguana.isTest() then
      return -- Don't bother to run it in production
   end
   local ExpectedSymbols = json.parse{data=Data}
   for K in pairs(_G) do
      if not ExpectedSymbols[K] then
         error("Symbol "..K.." is global when it should not be.",2)
      end
   end
end

local Help = {
   Title="CheckForGlobals",
   Usage="CheckForGlobals()",
   ParameterTable=false,
   Parameters={},
   Returns={},
   Examples={[[-- use require and local CheckForGlobals on separate lines
local CheckForGlobals = require 'tool.global.find'
main()
   CheckForGlobals()      
   -- other code goes here...
end]],
   [[-- combine require and the function call on a single line
require('tool.global.find')()]]},
   Desc=[[Finds any global symbols created in the code. Raises an error indicating the 
first global symbol (variable or function) found. To fix the error simply add "local" 
to start of the line containing the symbol declaration.
<br><br><b>Note:</b> You will need to repeat the process until no error is raised.
]],
   SeeAlso={
      {
         Title="Find Global Symbols",
         Link="http://help.interfaceware.com/v6/find-global-symbols"
      },
      {
         Title="Source code for the tool.global.find.lua module on github",
         Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/tool/global/find.lua"
      }
   },
}

help.set{input_function=CheckForGlobals, help_data=Help}


return CheckForGlobals