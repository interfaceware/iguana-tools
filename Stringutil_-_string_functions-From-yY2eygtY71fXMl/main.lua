-- http://help.interfaceware.com/code/details/stringutil-lua
-- This module extends the built in string library with a few useful extra functions
require 'stringutil'

local Input=[[
<patient firstName="JIM" lastName="bloggs   " title  = " MR " description=''/>
]]

local Description=[[
   Dr   Bob was not   renowned for    using very    consistent spacing.
]]

function main()
   local X = xml.parse{data=Input}
   
   -- Notice we have to convert to strings using :S() before
   -- we can use string functions
   
   -- Capitalize
   X.patient.firstName = X.patient.firstName:S():capitalize()
   
   -- Strip right hand white space then capitalize
   X.patient.lastName = X.patient.lastName:S():trimRWS():capitalize()
   
   -- Strip white space and capitalize
   X.patient.title = X.patient.title:S():trimWS():capitalize()
   
   -- Compact multiple white space and strip leading and trailing space
   X.patient.description = Description:compactWS():trimWS()
   
   trace(X)
end