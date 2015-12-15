-- hl7.findSegment is installed directly into the hl7 namespace
-- See http://help.interfaceware.com/code/details/hl7util-lua for the information about it
require 'hl7.findSegment'

-- code to find the PID segment in a parsed HL7 message
function main(Data)
   local Msg = hl7.parse{vmd='demo.vmd', data=Data}
   local PID = hl7.findSegment(Msg, FindPID)
end
 

function FindPID(Segment)
   if Segment:nodeName() == 'PID' then
      return true
   end
end