-- This module is useful if you'd like to be able to parse Z segments without going through the trouble of editing a VMD file
-- Read http://help.interfaceware.com/kb/generic-z-segment-parser for more information

require 'hl7.zsegment'
-- The parser gets inserted into the built in "hl7" namespace.


local Xml=[[
<Kin firstName='' lastName=''/>
]]

-- Because we don't know the grammar of the segments this module gives us the choice of pushing all the data
-- down to the lowest level leaf (compact=false)  This is safest but makes for verbose paths
-- Or we can keep the data at a higher level (assuming there are not sub fields and repeating fields)
function ParseZSegments(Data)
   -- This shows the compact parsing mode
   local CompactZED = hl7.zsegment.parse{data=Data, compact=true}   
   local X = xml.parse{data=Xml}
   X.Kin.firstName = CompactZED.ZID[1][2][2][1]
  
   -- This shows the non compact parsing mode
   local ExpandedZED = hl7.zsegment.parse{data=Data, compact=false}
   X.Kin.firstName = ExpandedZED.ZID[1][2][2][1][1]
end

