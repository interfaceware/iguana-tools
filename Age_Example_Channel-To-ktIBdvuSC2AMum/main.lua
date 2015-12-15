-- This example shows the use of the age module
-- This module calculates age from date of birth - it returns years, months and partial years.
-- http://help.interfaceware.com/code/details/age-lua

require 'dateparse'
local age = require 'age'

function main(Data)
   local Msg = hl7.parse{vmd ='example\\demo.vmd', data=Data}
   -- using dateparse allows common date formats
   local AgeYr, AgeMth, AgeDec = age.getAge(Msg.PID[7][1]:D())
   trace(AgeYr, AgeMth, AgeDec)
 
   AgeYr, AgeMth, AgeDec = age.getAge('19980210')
   trace(AgeYr, AgeMth, AgeDec)
 
   AgeYr, AgeMth, AgeDec = age.getAge('1998-02-10')   
   trace(AgeYr, AgeMth, AgeDec)   
end