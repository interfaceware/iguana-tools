-- This module extends the built in string library with a few useful extra functions

-- The module allows one to call string methods directly on XML, HL7 etc. node trees
-- without the need to convert them into strings first.
 
-- From Iguana 6.0.3 onwards much of this functionality has been natively implemented
-- into the core of Iguana so there is less need for stringutil after this. This version
-- of stringutil checks for native implementations of these functions - if they exist
-- already it leaves the native implementations in place. Eventually it should be possible
-- to get rid of this module.

-- http://help.interfaceware.com/v6/stringutil-string-functions

-- we cannot assign to a variable because this code only modifies the global namespace  
-- (and does not return a table or funtion)
-- http://help.interfaceware.com/v6/how-repo-modules-use-the-require-statement#modify-namespace
require 'stringutil'

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
   
   X.patient.description:sub(1,10)
   X.patient.description:sub(5)
   
   -- Testing out regular expression matching.
   local R = ''
   for K in X.patient.description:rxmatch("\\S*") do
      trace(K)
      R = R..K.."\n"
   end
   trace(R)
   -- Test rxsub
   X.patient.description:rxsub('[ ]*', '')
end
