local throttle = {}
 
-- Establish day and time values.
local function IsWeekday(Day)
-- Sunday == 1, Saturday == 7
return Day ~= 1 or Day ~= 7
end
 
local function IsPeakTime(Hours, Minutes)
   -- assuming peak time is 10:30 am (10:30) to 3:30 pm (15:30)
   return (Hours > 10 and Hours < 15) or
          (Hours == 10 and Minutes >= 30) or
          (Hours == 15 and Minutes <= 30)
end
 
-- Establish busiest time of day .
-- The definition of "peak period" will be dependent on the situation.
local function IsPeakPeriod()
   local Date = os.date("*t")

   local IsWeekdayValue = IsWeekday(Date.wday) -- wday range is (1-7)
   local IsPeakTimeValue = IsPeakTime(Date.hour, Date.min) -- hour range is (0-23)
   -- min range is (0-59)
   if IsWeekdayValue and IsPeakTimeValue
      then
      return true
   else
      return false
   end
end
 
-- Apply throttle to user-supplied function
function throttle.run(Method, Data)
   -- Use sleep to throttle user-supplied function for
   -- 100 milliseconds, but only during peak periods.
   if IsPeakPeriod() then
      util.sleep(100)
   end
   -- Execute user-supplied function
   Method(Data)
end

return throttle