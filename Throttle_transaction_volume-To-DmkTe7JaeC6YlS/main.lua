-- This example shows the use of the throttle module to limit the speed of transactions during core hours
-- This could be useful if you are running a data center that has multiple customers feeding into it 
-- i.e. a 'multi-tenant' architecture in jargon speak.
-- If you have one client that is flooding the centre with too much data then you might want to throttle the
-- the traffic from that client to stop their feed from hogging resources from the rest of the customers.

-- See http://help.interfaceware.com/v6/throttle

local throttle = require 'throttle'

-- "Static" values for weekdays for readability when creating schedules
local SUN=1 local MON=2 local TUE=3 local WED=4 
local THU=5 local FRI=6 local SAT=7


local function ExpensiveOperation1(Data)
  -- do something that takes a lot of resources    
end

local function ExpensiveOperation2(Data, MoreData, Comment)
   -- do something that takes a lot of resources    
end

function main(Data)
   -- throttle for default peak hours times from 10:30 am (10:30) to 3:30 pm (15:30)
   throttle.run(ExpensiveOperation1, Data)

   -- NOTE: throttle.run() can handle (optional) multiple parameters
   throttle.run(ExpensiveOperation2, Data, 123456, 'Hello world')
   
   -- The examples below show how you can change scheduled times from the default
   -- hours by passing a "schedule table" to the throttle.modifySchedule() function
   -- the "schedule table" is simply a standard Lua table format 
   -- simply modify an example to create your own schedule

   -- extra delay added for Saturday as well
   throttle.modifySchedule({
      [MON]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
      [TUE]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
      [WED]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
      [THU]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
      [FRI]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
      [SAT]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}}
   })
   throttle.run(ExpensiveOperation1, Data)

	-- multiple delays on each day for peak times and 
   -- to reduce conflicts with scheduled overnight backups
   throttle.modifySchedule({
      [MON]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=50},    -- less busy = less delay
             {Start={hr=01,min=00},End={hr=03,min=00},Delay=100}},  -- daily incremental backup
      [TUE]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=50},
             {Start={hr=01,min=00},End={hr=03,min=00},Delay=100}},
      [WED]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=50},
             {Start={hr=01,min=00},End={hr=03,min=00},Delay=100}},
      [THU]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100},   -- busier = increase delay
             {Start={hr=01,min=00},End={hr=03,min=00},Delay=100}},
      [FRI]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100},
             {Start={hr=01,min=00},End={hr=03,min=00},Delay=100}},
      [SAT]={{Start={hr=01,min=00},End={hr=03,min=00},Delay=100}},  -- only daily incremetal needed
      [SUN]={{Start={hr=01,min=00},End={hr=03,min=00},Delay=200}}   -- longer delay for full backup
   })
   throttle.run(ExpensiveOperation1, Data)

end