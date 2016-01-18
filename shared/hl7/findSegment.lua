-- The hl7.findSegment module
-- Copyright (c) 2011-2015 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in accordance
-- with the terms of the iNTERFACEWARE license agreement accompanying the software
-- in which it is used.
 
-- General purpose routine to iterate through a message tree and find a segment matching the Filter function given.
function hl7.findSegment(Msg, Filter)
   local segments = {}
   local cnt = 0
   for i=1, #Msg do
      if (Msg[i]:nodeType() == 'segment'
            and Filter(Msg[i])) then
         cnt = cnt + 1
         segments[cnt] = Msg[i]
      end
   end
   if cnt>0 then 
      return segments[1], segments 
   end
   for i=1, #Msg do
      local T = Msg[i]:nodeType()
      if (T == 'segment_group'
            or T == 'segment_group_repeated'
            or T == 'segment_repeated') then
         local R1, R2 = hl7.findSegment(Msg[i], Filter)
         if R1 ~= nil then
            return R1, R2
         else 
            return nil, nil
         end
      end
   end
end
 
local hl7_findSegment = {
   Title="hl7.findSegment";
   Usage="hl7.findSegment(Msg, Filter)",
   SummaryLine="Find segment(s) in a parsed HL7 message using a filter function.",
   Desc=[[Find one or more matching segments in a parsed HL7 message using a 
   filter function. 
   <p>The first  return contains the first matching segment as an hl7 node, 
   the second return contains a table of matching hl7 nodes, if no matching
   segments are found then both returns are nil.
   ]];
   Returns = {
      {Desc="Returns the first identified segment (node)  <u>hl7 node</u>."},
      {Desc="Returns one or more identified segments (nodes)  <u>table of nodes</u>."},
   };
   ParameterTable= false,
   Parameters= {
      {Msg= {Desc='Parsed HL7 message node tree <u>hl7 node tree</u>.'}},
      {Filter= {Desc='Filter function to identify segment(s) <u>function</u>.'}},
   };
   Examples={
      [[   -- hl7.findSegment is installed directly into the hl7 namespace
   require 'hl7.findSegment'

   -- http://help.interfaceware.com/code/details/hl7util-lua

   function main(Data)
      local Msg = hl7.parse{vmd='demo.vmd', data=Data}

      -- find the PID segment in the parsed HL7 message
      -- returns a single segment node
      local PID = hl7.findSegment(Msg, FindPID)

      -- find the NK1 segment(s) in the parsed HL7 message
      -- returns a table of segment nodes
      local NK1 = hl7.findSegment(Msg, FindNK1)
   end
      
   -- function to find (match) a PID segment
   function FindPID(Segment)
      if Segment:nodeName() == 'PID' then
         return true
      end
   end
      
   -- function to find (match) a NK1 segment(s)
   function FindNK1(Segment)
      if Segment:nodeName() == 'NK1' then
         return true
      end
   end]],
   };
   SeeAlso={
      {
         Title="hl7.findSegment.lua - in our code repository",
         Link="http://help.interfaceware.com/code/details/hl7util-lua"
      },
      {
         Title="hl7.findSegment",
         Link="http://help.interfaceware.com/v6/hl7-findsegment"
      }
   }
}

help.set{input_function=hl7.findSegment, help_data=hl7_findSegment}
