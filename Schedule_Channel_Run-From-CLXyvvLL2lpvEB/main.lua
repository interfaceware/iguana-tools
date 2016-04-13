-- This scheduler script can be used to run a script at a given time

-- http://help.interfaceware.com/v6/scheduler-example

local scheduler = require 'scheduler'
 
-- Within the editor we run the function all the time.
local function DoBatchProcess(Data)
   iguana.logInfo('Processed a big batch of data!')
end
 
function main()
   scheduler.runAt(11.5, DoBatchProcess, "Some Argument")   
end