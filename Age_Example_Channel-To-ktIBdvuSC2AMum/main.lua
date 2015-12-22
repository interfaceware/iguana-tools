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
   local AgeYr, AgeMth, AgeDec = age.getAge(Msg.PID[7][1]:nodeValue())
   trace(AgeYr, AgeMth, AgeDec)
   
   -- age.lua uses dateparse to supports non-conformant date formats
   local AgeYr, AgeMth, AgeDec = age.getAge('01/10/1948')
   trace(AgeYr, AgeMth, AgeDec)
end