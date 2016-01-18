require 'stringutil'
-- This module extends the built in string library with a few useful extra functions
-- http://help.interfaceware.com/code/details/stringutil-lua

local Input=[[
<patient firstName="JIM" lastName="bloggs   " title  = " MR " description=''/>
]]

local Description=[[
   Dr   Bob was not   renowned for    using very    consistent spacing.
]]

function main()
   local X = xml.parse{data=Input}   
   -- Capitalize
   X.patient.firstName = X.patient.firstName:capitalize()
   
   -- Strip right hand white space then capitalize
   X.patient.lastName = X.patient.lastName:S():trimRWS():capitalize()
   
   -- Strip white space and capitalize
   X.patient.title = X.patient.title:trimWS():capitalize()
   
   -- Compact multiple white space and strip leading and trailing space
   X.patient.description = Description:compactWS():trimWS()
   trace(X)
   -- Convert to strings to see the annotations easily
   X.patient.title:S()
   X.patient.firstName:S()
   X.patient.lastName:S()
   X.patient.description:S()
  
   
end