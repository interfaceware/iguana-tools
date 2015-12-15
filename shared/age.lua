local age = {}
 
local function isLeapYr(Year)
   if math.fmod(Year/400,1) == 0 then
      return true
   end
   
   if math.fmod(Year/4,1) == 0 and math.fmod(Year/100,1) ~= 0 then
      return true
   end
   return false
end
 
local function calcYrs(DOB)
   local _, dob = dateparse.parse(DOB)
   
   local T = os.time()
   local ageSecs = os.difftime(T, os.time{
         year = dob.year, 
         month = dob.month, 
         day = dob.day})
 
   local currY = tonumber(os.ts.date('%Y'))
   local yrs = 0
   local YRSEC = 365*24*3600
   local LPYRSEC = 366*24*3600
 
   local secs = ageSecs
   for i = dob.year, currY do
      if isLeapYr(i) then
         secs = secs - LPYRSEC
         yrs = yrs + 1
         if secs < YRSEC then
            return yrs, yrs + secs/YRSEC, secs
         end
      else
         secs = secs - YRSEC
         yrs = yrs + 1
         if isLeapYr(1 + 1) then
            if secs < LPYRSEC then
               return yrs, secs/LPYRSEC, secs
            end
            else
            if secs < YRSEC then             
               return yrs, yrs + secs/YRSEC, secs          
            end          
         end       
      end    
   end 
end 

local function calcMths(DOB)    
   local _, dob = dateparse.parse(DOB)    
   local _, currDt = dateparse.parse(os.date())    
   local ageMths    
   if currDt.month > dob.month then
      ageMths = currDt.month - dob.month
      trace(ageMths)
   elseif currDt.month == dob.month then
      ageMths = 0
      trace(ageMths)
   else
      ageMths = 12 + (currDt.month - dob.month)
   end
   return ageMths
end
  
function age.getAge(DOB)   
   -- calculate years
   local ageYrs, ageDec = calcYrs(DOB)
   -- calculate months
   local ageMths = calcMths(DOB)
   return ageYrs, ageMths, ageDec
end
 
return age