-- This module is used to help generate random HL7
-- data using the translator.

-- http://help.interfaceware.com/v6/random-message-generator

-- seed data used for generation
local data = {}
data.Sex = {'M', 'F'}
data.LastNames = {'Muir','Smith','Adams','Garland', 'Meade', 'Fitzgerald', 'WHITE'}
data.MaleNames = {'Fred','Jim','Gary','John'}
data.FemaleNames = {'Mary','Sabrina','Tracy'}
data.Race = {'AI', 'EU', 'Mixed', 'Martian', 'Unknown'}
data.Street = {'Delphi Cres.', 'Miller Lane', 'Yonge St.', 'Main Rd.'}
data.Relation = {'Grandchild', 'Second Cousin', 'Sibling', 'Parent'}
data.Event = {'A01', 'A03', 'A04', 'A05', 'A06', 'A07', 'A08'}
data.Facility = {'Lab', 'E&R'}
data.Application = { 'AcmeMed', 'MedPoke', 'CowZing' }
data.Locations = { {'Chicago', 'IL'}, {'Toronto', 'ON'}, {'ST. LOUIS', 'MO'}, {'LA', 'CA'} }

local function rand(In, Max, Size)
   local Result = tostring((In + math.random(Max)) % Max)
   if '0' == Result then
      Result = '1'
   end
   
   while Size > Result:len() do
      Result = '0'..Result
   end
   return Result
end

local function ranChoose(T)
   return T[math.random(#T)]
end

local function ranTimeStamp()
   local T = os.date('*t')
   
   local newDate = '20'..rand(T.year,tostring(T.year):sub(-2),2)..
   rand(T.month,12,2)..
   rand(T.day,29,2)..
   rand(T.hour,12,2)..
   rand(T.min,60,2)..
   rand(T.sec,60,2)
   
   return newDate
end

local function ranNameAndSex(PID)
   if math.random(2) == 1 then
      PID[8] = 'M'
      PID[5][1][2] = ranChoose(data.MaleNames)
   else   
      PID[8] = 'F'
      PID[5][1][2] = ranChoose(data.FemaleNames)      
   end
end

local function ranLastName() return ranChoose(data.LastNames) end

local function ranDate()
   local T = os.date('*t')
  
   local newDate = '19'..rand(T.year,99,2)..
   rand(T.month,12,2)..
   rand(T.day,29,2)
   
   return newDate
end

local function ranAcctNo()
   return math.random(99)..'-'..math.random(999)..'-'..math.random(999)
end

local function ranLocation()
   local R = ranChoose(data.Locations)
   return R[1], R[2]
end

local function ranSSN()
   return math.random(999)..'-'
          ..math.random(999)..'-'
          ..math.random(999)
end

local function ranFirstName()
   if math.random(2) == 1 then
      return ranChoose(data.MaleNames)
   else   
      return ranChoose(data.FemaleNames)      
   end
end

local function ranScrubMSH(MSH)
   MSH[3][1] = ranChoose(data.Application)
   MSH[4][1] = ranChoose(data.Facility)
   MSH[5][1] = 'Main HIS'
   MSH[6][1] = 'St. Micheals'
   MSH[7][1] = ranTimeStamp()
   MSH[9][1] = 'ADT'
   MSH[9][2] = ranChoose(data.Event)
   MSH[10] = util.guid(256)
   MSH[11][1] = 'P'
   MSH[12][1] = '2.6'
   MSH:S()
end

local function ranScrubEVN(EVN)
   EVN[2][1] = ranTimeStamp()
   EVN[6][1] = ranTimeStamp()
end

local function ranScrubPID(PID)
   PID[3][1][1] = math.random(9999999)
   ranNameAndSex(PID)
   PID[5][1][1][1] = ranLastName()
   PID[7][1] = ranDate()
   PID[10][1][1] = ranChoose(data.Race)
   PID[18][1] = ranAcctNo()
   PID[11][1][3], PID[11][1][4] = ranLocation()
   PID[11][1][5] = math.random(99999)
   PID[11][1][1][1] = math.random(999)..
      ' '..ranChoose(data.Street)
   PID[19] = ranSSN()
   PID:S()
end

local function ranPV1(PV1)
   PV1[8][1][2][1] = ranLastName()
   PV1[8][1][3] = ranFirstName()
   PV1[8][1][4] = 'F'
   PV1[19][1] = math.random(9999999)
   PV1[44][1] = ranTimeStamp()
   PV1:S()
end

local function ranKin(NK1)
   NK1[2][1][1][1] = ranLastName()  
   NK1[2][1][2] = ranFirstName()
   NK1[3][1] = ranChoose(data.Relation)
end

local function ranNK1(NK1)
   for i = 1, math.random(6) do
      NK1[i][1] = i
      ranKin(NK1[i])
   end
end

local function ranAddWeight(Out)
   local OBX = Out.OBX[#Out.OBX+1]
   OBX[3][1] = 'WT'
   OBX[3][2] = 'WEIGHT'
   OBX[5][1][1] = math.random(100) + 30
   OBX[6][1] = 'pounds'
   return OBX
end
   
local function ranAddHeight(Out)
   local OBX = Out.OBX[#Out.OBX+1]
   OBX[3][1] = 'HT'
   OBX[3][2] = 'HEIGHT'
   OBX[5][1][1] = math.random(100) + 20
   OBX[6][1] = 'cm'
   return OBX
end

local function RandomMessage()
   local Out = hl7.message{vmd='random/generator.vmd', name='ADT'} 
   ranScrubMSH(Out.MSH)
   ranScrubEVN(Out.EVN)
   ranScrubPID(Out.PID)
   ranPV1(Out.PV1)
   ranNK1(Out.NK1)
   ranAddWeight(Out)
   ranAddHeight(Out)
   return Out:S()   
end

local HELP_DEF={
   SummaryLine = "Generates HL7 sample messages",
   Desc = "Generates sample HL7 ADT messages from the seed data (hard-coded into the module)",
   Usage = "ran.RandomMessage()",
   ParameterTable=false,
   Parameters = none,
   Returns = {{Desc='A generated HL7 ADT message <u>string</u>'}},
   Title = 'ran.RandomMessage',  
   SeeAlso = {{Title='Source code for the ran.lua module on github', Link='https://github.com/interfaceware/iguana-tools/blob/master/shared/ran.lua'},
      {Title='HL7 Random Message Generator', Link='http://help.interfaceware.com/v6/random-message-generator'}},
   Examples={'data=ran.RandomMessage()'}
}
 
help.set{input_function=RandomMessage,help_data=HELP_DEF}

return RandomMessage