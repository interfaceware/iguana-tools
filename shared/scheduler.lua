-- This scheduler module can be used to run a script at a given time

-- http://help.interfaceware.com/v6/scheduler-example

local LastRunTime = 0
local ScheduledRunTime = 0

local function NextRunTime(Hour, LastRunTime)
   local T = os.ts.date('*t')
   T.hour = Hour
   T.min = (Hour - math.floor(Hour)) * 60
   T.sec = 0
   local NextTime = os.ts.time(T)
   local LastT = os.ts.date('*t', LastRunTime)
   os.ts.date("%c", LastRunTime)
   if os.ts.difftime(LastRunTime, NextTime) > 0 then
      NextTime = NextTime + 24*60*60
   end
   return NextTime, os.ts.date("%c", NextTime)
end

local function RunFileName()
   return iguana.channelName():gsub('%s','_')..'_LastScheduledTime.txt'
end

local function LastRun()
   if not os.fs.access(RunFileName()) then
      return 0, 'No recorded run'
   end
   local F = io.open(RunFileName(), 'r')
   local T = F:read('*a')
   F:close()
   return tonumber(T), 'Last run at '..os.ts.date('%c', tonumber(T))
end

local function Status(LastRun, ScheduledTime)
   local R
   if LastRun ~= 0 then
      R = 'Last run at '..os.ts.date('%c', LastRun)
   else
      R = 'Has not run yet.'
   end
   R = R..'\nScheduled to run at '..os.ts.date('%c',ScheduledTime)

   iguana.setChannelStatus{color='green', text=R}

   return R
end

local function RecordRun(ScheduledHour)
   if iguana.isTest() then return end
   local R = os.ts.time()
   local F = io.open(RunFileName(), 'w')
   F:write(R)
   F:close()
   LastRunTime = R
   ScheduledRunTime = NextRunTime(ScheduledHour, LastRunTime)
   local R  = Status(LastRunTime, ScheduledRunTime)
   iguana.logInfo(R)
end

local function Init(Time)
   LastRunTime = LastRun()
   ScheduledRunTime = NextRunTime(Time, LastRunTime)
   local R = Status(LastRunTime, ScheduledRunTime)
   iguana.logInfo(R)
   return R
end

-- the "..." syntax means multiple functions that multiple
-- (optional) parameters can be passed to the function in 
-- a table named "arg" - these are passed to the function
-- by converting them using the "unpack" function
local function runAt(scheduledHour, func, ...)
   local R
   trace(LastRunTime)
   if LastRunTime == 0 or iguana.isTest() then
      -- We need to do one time initialization
      R = Init(scheduledHour)
   end
   trace(ScheduledRunTime)
   local WouldRun = (os.ts.time() > ScheduledRunTime and LastRunTime <= ScheduledRunTime)
   trace("Would run = "..tostring(WouldRun))

   if WouldRun then
      iguana.logInfo('Kicking off batch process')
      func(unpack(arg))
      RecordRun(scheduledHour)
      return R
   end
   if iguana.isTest() then
      func(unpack(arg))
      return R
   end

   return R
end

local HELP_DEF={
   SummaryLine = "Run a channel at a scheduled time",
   Desc =[[Runs a channel once at the specified scheduled time (actually runs
it the first time that the scheduled time is exceeded)]],
   Usage = "scheduler.runAt(scheduledHour, ...)",
   ParameterTable=false,
   Parameters ={
      {scheduledHour={Desc='The hour to run the function <u>number</u>.'}}, 
      {func={Desc='The function to call <u>function</u>.'}}, 
      {['...']={Desc='One or more arguments to the function <u>any type</u>.', Opt=true}},
   },
   Returns ={{Desc='Status message indicating schedule time and when/whether the function was run <u>string</u>.'}},
   Title = 'scheduler.runAt',  
   SeeAlso = {{Title='scheduler.lua module on github', Link='https://github.com/interfaceware/iguana-tools/blob/master/Schedule_Channel_Run-From-CLXyvvLL2lpvEB/main.lua'},
      {Title='Schedule Channel Run', Link='http://help.interfaceware.com/v6/scheduler-example'}},
   Examples={'scheduler.runAt(11.5, DoBatchProcess")',
      'scheduler.runAt(11.5, DoBatchProcess, "Some Argument")',
      [[-- Note: runAt can handle (optional) multiple parameters
scheduler.runAt(11.5, DoBatchProcess, 'Some Argument', "Second Argument", "etc...")]],
   }
}
 
help.set{input_function=runAt,help_data=HELP_DEF}

return runAt