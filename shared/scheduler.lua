local scheduler={}
 
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

local function trace(M) end

function scheduler.runAt(ScheduledHour, Func, Arg)
   local R
   trace(LastRunTime)
   if LastRunTime == 0 or iguana.isTest() then
      -- We need to do one time initialization
      R = Init(ScheduledHour)
   end
   trace(ScheduledRunTime)
   local WouldRun = (os.ts.time() > ScheduledRunTime and LastRunTime <= ScheduledRunTime)
   trace("Would run = "..tostring(WouldRun))

   if WouldRun then
      iguana.logInfo('Kicking off batch process')
      Func(Arg)
      RecordRun(ScheduledHour)
      return R
   end
   if iguana.isTest() then
      Func(Arg)
      return R
   end

   return R
end

return scheduler