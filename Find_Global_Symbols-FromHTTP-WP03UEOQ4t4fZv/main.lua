-- See http://help.interfaceware.com/v6/find-global-symbols
-- On the whole it's best practice not to define global symbols in
-- Lua translator instances because it introduces a point of maintainance
-- pain if those symbols get re-used elsewhere.
-- Follow the steps outlined below to get rid of the error.

local CheckForGlobals = require 'tool.global.find'

-- Step 1 - Change this line to be local function MyUnintendedGlobal()
-- This will change it into a local function and resolve the exception
function MyUnintendedGlobal()
   
end

function main(Data)
   MyUnintendedGlobal()
   
   -- Step 2 - Click on the CheckForGlobals annotation and see how it works.
   CheckForGlobals()
   
   net.http.respond{body='The channel is working correctly with no globals.'}   
end

