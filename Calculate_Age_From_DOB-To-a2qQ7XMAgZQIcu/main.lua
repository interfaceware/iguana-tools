-- This example shows the use of the age module
-- This module calculates age from date of birth - it returns years, months and partial years.
-- http://help.interfaceware.com/code/details/age-lua

local age = require 'age'

function main(Data)   
   local Msg = hl7.parse{vmd ='example\\demo.vmd', data=Data}

	-- getAge() requires date as a string parameter
   AgeYr, AgeMth, AgeDec = age.getAge('19980210')
   trace(AgeYr, AgeMth, AgeDec)
 
   AgeYr, AgeMth, AgeDec = age.getAge('1998-02-10')   
   trace(AgeYr, AgeMth, AgeDec)

   -- use :nodeValue() as getAge() requires date as a string
   local AgeYr, AgeMth, AgeDec = age.getAge(Msg.PID[7][1])
   trace(AgeYr, AgeMth, AgeDec)
   
   -- age.lua uses dateparse to support non-conformant date formats
   local AgeYr, AgeMth, AgeDec = age.getAge('01/10/1948')
   trace(AgeYr, AgeMth, AgeDec)
   
   -- if today is the birthday and time are not specified, age is
   -- how old the person turns today.
   local today = os.date('*t')
   local dob1 = (today.year - 10) .. '-' .. today.month .. '-' .. today.day
   local dob2 = (today.year - 1) .. '-' .. today.month .. '-' .. today.day

   AgeYr1 = age.getAge(dob1) -- turning 10 years old today
   AgeYr2 = age.getAge(dob2) -- turning 1 year old today
   trace(AgeYr1,AgeYr2)
end