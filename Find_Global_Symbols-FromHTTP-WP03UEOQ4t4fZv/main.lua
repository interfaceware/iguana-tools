-- On the whole it's best practice not to define global symbols in
-- Lua translator instances because it introduces a point of maintenance
-- pain if those symbols get re-used elsewhere.
-- Follow the steps outlined below to get rid of the error.

-- http://help.interfaceware.com/v6/find-global-symbols

local CheckForGlobals = require 'tool.global.find'

-- Step 1 - Change this line to be local function MyUnintendedGlobal()
-- This will change it into a local function and resolve the exception
function MyUnintendedGlobalFunction()
   
end

-- Step 2 - Change this line to be local function MyUnintendedGlobal()
-- This will change it into a local function and resolve the exception
MyUnintendedGlobalVariable = "oops I am global"

function main(Data)
   MyUnintendedGlobalFunction()
   
   -- Step 3 - Click on the CheckForGlobals() annotation and see how it works.
   CheckForGlobals()
   
   net.http.respond{body='The channel is working correctly with no globals.'}   
end