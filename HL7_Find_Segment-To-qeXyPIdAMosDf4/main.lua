-- hl7.findSegment is installed directly into the hl7 namespace
require 'hl7.findSegment'

-- For more discussion read:
-- http://help.interfaceware.com/code/details/hl7util-lua

function main(Data)
   local Msg = hl7.parse{vmd='demo.vmd', data=Data}
   
   -- find the PID segment(s) in the parsed HL7 message
   -- first returns contains the first matching node
   -- second return contains a table of matching nodes
   local PID, TbPID = hl7.findSegment(Msg, FindPID)
   trace(PID)
   trace(TbPID)

   -- find the NK1 segment(s) in the parsed HL7 message
   local NK1, TbNK1 = hl7.findSegment(Msg, FindNK1)
   trace(NK1)
   trace(TbNK1)
   
   -- find grandchild 
   local NK1 = hl7.findSegment(Msg, FindGrandChild)
   trace(NK1[2][1][2].." "..NK1[2][1][1][1].." is a grandchild!")
end
 
-- function to find (match) a PID segment
function FindPID(Segment)
   if Segment:nodeName() == 'PID' then
      return true
   end
end

-- function to find (match) NK1 segment(s)
function FindNK1(Segment)
   if Segment:nodeName() == 'NK1' then
      return true
   end
end

-- function to match NK1 segments where
-- the relationship is Grandchild
function FindGrandChild(Segment)
   if Segment:nodeName() == 'NK1' then
      if Segment[3][1]:S() == "Grandchild" then
         return true
      end
   end   
end