-- The parser gets inserted into the built in "hl7" namespace.
require 'hl7.zsegment'

-- This module is useful if you'd like to be able to parse Z segments without going through the trouble of editing a VMD file
-- http://help.interfaceware.com/kb/generic-z-segment-parser for more information

local Xml=[[
<Kin firstName='' lastName=''/>
]]

-- Because we don't know the grammar of the segments this module gives us the choice of pushing all the data
-- down to the lowest level leaf (compact=false)  This is safest but makes for verbose paths
-- Or we can keep the data at a higher level (assuming there are not sub fields and repeating fields)
function main(Data)
   local X = xml.parse{data=Xml}
   
   -- This shows the non compact parsing mode
   local ExpandedZED = hl7.zsegment.parse{data=Data, compact=false}
   X.Kin.firstName = ExpandedZED.ZID[1][2][2][1][1]
   X.Kin.lastName = ExpandedZED.ZID[1][2][2][2][1]
   
   -- This shows the compact parsing mode
   local CompactZED = hl7.zsegment.parse{data=Data, compact=true}   
   X.Kin.firstName = CompactZED.ZID[1][2][2][1]
   X.Kin.lastName = CompactZED.ZID[1][2][2][2][1]
   
   -- Example of how results vary depending whether the 
   -- "Mr" subfield is included after the surname
   -- Note: "Mr" is included in 1st message but removed in the 2nd 
  
   -- expanded mode path always finds the surname "Smith"
   trace(ExpandedZED.ZID[1][2][2][2][1])
   
   -- compact mode needs different paths for each case
   trace (CompactZED.ZID[1][2][2][2][1]) -- only works with "Mr"
   trace (CompactZED.ZID[1][2][2][2])    -- only works without "Mr"
end