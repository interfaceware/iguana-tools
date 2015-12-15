-- The hl7.findSegment module
-- Copyright (c) 2011-2015 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in accordance
-- with the terms of the iNTERFACEWARE license agreement accompanying the software
-- in which it is used.
 
-- General purpose routine to iterate through a message tree and find a segment matching the Filter function given.
function hl7.findSegment(Msg, Filter)
   for i=1, #Msg do
      if (Msg[i]:nodeType() == 'segment'
            and Filter(Msg[i])) then
         return Msg[i]
      end
   end
   for i=1, #Msg do
      local T = Msg[i]:nodeType()
      if (T == 'segment_group'
            or T == 'segment_group_repeated'
            or T == 'segment_repeated') then
         local R = hl7.findSegment(Msg[i], Filter)
         if R ~= nil then
            return R
         end
      end
   end
end
 
