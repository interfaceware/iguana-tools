-- This module limits how quickly transactions are processed during the peak hours
-- NOTE: peak hour times are hard-coded in the function IsPeakTime()

-- This example shows the use of the throttle module to limit the speed of transactions during core hours
-- This could be useful if you are running a data center that has multiple customers feeding into it 
-- i.e. a 'multi-tenant' architecture in jargon speak.
-- If you have one client that is flooding the centre with too much data then you might want to throttle the
-- the traffic from that client to stop their feed from hogging resources from the rest of the customers.

-- See http://help.interfaceware.com/v6/throttle

local throttle={}

-- "Static" values for weekdays for readability when creating schedules
local SUN=1 local MON=2 local TUE=3 local WED=4 
local THU=5 local FRI=6 local SAT=7


-- default schedule is for 100 milliseconds delay during "standard"
-- peak hours times from 10:30 am (10:30) to 3:30 pm (15:30) for Mon to Fri
local S ={
   [MON]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
   [TUE]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
   [WED]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
   [THU]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
   [FRI]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}}
}

-- checks the schedule and returns the milliseconds delay extracted
-- from schedule table "S"
local function scheduledDelay(Day, Hours, Minutes)   
   for i,j in pairs(S) do
      trace(i,j)
      if i == Day then
         for m,n in ipairs(j) do
            trace(m,n)
            if (Hours > n.Start.hr and Hours < n.End.hr) or
               (Hours == n.Start.hr and Minutes >= n.Start.min) or 
               (Hours == n.End.hr and Minutes <= n.End.min)
               then
                  return n.Delay
            end
         end
      end 
   end
   return 0 -- current time is not in shedule table = no delay
end

-- modify the schedule
function throttle.modifySchedule(Schedule)
   if Schedule then S = Schedule end
	trace(S)
end
 
-- Apply throttle to user-supplied function
-- NOTE: The "..." syntax means multiple functions that multiple
-- (optional) parameters can be passed to the function in 
-- a table named "arg" - these are passed to the function
-- by converting them using the "unpack" function
function throttle.run(Method, ...)
   -- Use sleep to throttle user-supplied function for
   -- 100 milliseconds, but only during peak periods.
   local D = os.date("*t")

   local delay = scheduledDelay(D.wday, D.hour, D.min)
   if delay > 0 then
      util.sleep(delay)
   end
   
   -- Execute user-supplied function
   Method(unpack(arg))
end

local Help = {
   Title="throttle.modifySchedule",
   Usage="throttle.modifySchedule(scheduleTable)",
   Summary='Modifies the "Delay Schedule".',
   ParameterTable=false,
   Parameters={
      {connection={Desc="Live database connection."}}
   },
   Returns={},
   Examples={[[-- delay only required for peak times on Thu and Fri
throttle.modifySchedule({
   [THU]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}},
   [FRI]={{Start={hr=10,min=15},End={hr=15,min=30},Delay=100}}
})]],
	[[-- multiple delays on each day for peak times and 
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
})]]},
   Desc=[[Modifies the "Delay Schedule" table, by replacing it with a new schedule table. 
The delay schedule is simply a Lua table containing entries for Start and End times with 
a Delay in milliseconds.<br><br>
<b>Note:</b>The Start and End times are represented as Hours and Minutes
(because it made for simpler code than using time values).]],
   SeeAlso={
      {
         Title="Throttle Transaction Volume",
         Link="http://help.interfaceware.com/v6/throttle"
      },
      {
         Title="Source code for the throttle.lua module on github",
         Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/throttle.lua"
      }
   },
}

help.set{input_function=throttle.modifySchedule, help_data=Help}

local Help = {
   Title="throttle.run",
   Usage="throttle.run(Method, ...)",
   ParameterTable=false,
   Parameters={
      {connection={Desc="Function to call <u>function</u>."}},
      {['...']={Desc="One or more arguments to the function <u>any type</u>.", Opt=true}}
   },
   Returns={},
   Examples={[[-- throttle for default peak hours times from 10:30 am (10:30) to 3:30 pm (15:30)
throttle.run(ExpensiveOperation1, Data)]],
   [[-- throttle.run() also works with multiple parameters
throttle.run(ExpensiveOperation2, Data, 123456, 'Hello world')]]
},
   Desc=[[Runs a function using the delay in ms specified in the "Delay Schedule" table. 
<br><br><b>Note:</b>The default schedule uses a 100 millisecond delay for Mon to Fri peak times 
from 10:30 am (10:30) to 3:30 pm (15:30).
]],
   SeeAlso={
      {
         Title="Throttle Transaction Volume",
         Link="http://help.interfaceware.com/v6/throttle"
      },
      {
         Title="Source code for the throttle.lua module on github",
         Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/throttle.lua"
      }
   },
}

help.set{input_function=throttle.run, help_data=Help}


return throttle