calendar_financial = {}

local MonthLookup={"Jan","Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct","Nov", "Dec"} 

function calendar_financial.convert(T)
   local StartMonth = T.start_month or 1
   local Time = T.time
   local TT= os.ts.date("*t", Time)
   
   local Year = TT.year
   if TT.month < StartMonth then
      Year = Year - 1
   end
   local Quarter = TT.month - T.start_month 
   if Quarter < 0 then Quarter = Quarter + 12 end
         
   trace(Quarter)
   local Month = (Quarter % 3) + 1
   trace(Month)
   Quarter=math.floor(Quarter / 3)+1
   trace(Quarter)
   
   
   Quarter = "Q"..Quarter
   return Year, Quarter, MonthLookup[TT.month], Month
end

local ConvertHelp=[[{
   "Returns": [{"Desc": "Financial year (Integer)"}, { "Desc" : "Financial Quarter (string)"}, {"Desc" : "Month (string)"}, {"Desc" : "Order of month in quarter (integer)"}],
   "Title": "config.load",
   "Parameters": [
      { "time": {"Desc": "Time in seconds since 1970 in UTC time."}},
      { "start_month": {"Desc": "The month as an integer that is the start of the financial year. i.e. 1 is for January"}}],
   "ParameterTable": true,
   "Usage": "local Year, Quarter, Month = calendar_financial.convert{time=os.ts.time()- 24*60*60*200}",
   "Examples": [
      "--Get the current time and substract 200 days worth of seconds
local Year, Quarter, Month = calendar_financial.convert{time=os.ts.time()- 24*60*60*200}"
   ],
   "Desc": "This function converts a UTC time into the financial year, quarter and month."
}]]

help.set{input_function=calendar_financial.convert, help_data=json.parse{data=ConvertHelp}}


return calendar_financial