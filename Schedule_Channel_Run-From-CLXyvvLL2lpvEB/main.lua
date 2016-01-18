-- http://help.interfaceware.com/code/details/scheduler-lua
-- This scheduler script can be used to run a script at a given time
scheduler = require 'scheduler'
 
-- Within the editor we run the function all the time.
local function DoBatchProcess(Data)
   iguana.logInfo('Processed a big batch of data!')
end
 
function main()
   scheduler.runAt(11.5, DoBatchProcess, "Some Argument")   
end