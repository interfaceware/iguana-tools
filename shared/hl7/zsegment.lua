-- Generic Z segment parser - read d http://help.interfaceware.com/kb/generic-z-segment-parser for more information.

hl7.zsegment = {}

local function ParseDelim(Data, DelimArray, Index, Compact)
   if Index == 0 then
      return Data
   end
   local Children = Data:split(DelimArray[Index])
   local Result = {}
   if #Children > 1  then
      for i =1, #Children do
         Result[i] = ParseDelim(Children[i], DelimArray, Index-1, Compact)   
      end
   else
      if Compact then
         Result = ParseDelim(Data, DelimArray, Index-1, Compact)
      else
         Result[1] = ParseDelim(Data, DelimArray, Index-1, Compact)
      end
   end
   
   return Result
end


local function AddZSegment(List, Segment, Compact)
   local Fields = Segment:split('|')
   local SegmentName = Fields[1]
   for i=2, #Fields do 
      Fields[i-1] = ParseDelim(Fields[i], {'&','^','~'}, 3, Compact)
   end
   if not List[SegmentName] then
      List[SegmentName] = {} 
   end
   List[SegmentName][#List[SegmentName]+1] = Fields
end


function hl7.zsegment.parse(T)
   local Segments = T.data:split("\r")
   local ZSegments = {}
   for i = 1,#Segments do
      if Segments[i]:sub(1,1) == 'Z' then
         AddZSegment(ZSegments, Segments[i], T.compact)
      end
   end
   return ZSegments
end

local HELP_DEF=[[{
   "Desc": "Parses an HL7/EDI/X12 message and extracts Z segments which it returns in a Lua table. ",
   "Returns": [
      {
         "Desc": "A lua table with the Z segments parsed out."
      }
   ],
   "SummaryLine": "Parses an HL7/EDI/X12 message for Z-zegments without a vmd.",
   "SeeAlso": [
      {
         "Title": "Parsing Z segments without a vmd.",
         "Link": "http://help.interfaceware.com/kb/generic-z-segment-parser"
      }
   ],
   "Title": "hl7.zsegment.parse",
   "Usage": "hl7.zsegment.parse{data=&#60;value&#62;, compact=&#60;true|false&#62;}",
   "Parameters": [
      {
         "data": {
            "Desc": "A message to be parsed <u>string</u>. "
         }
      },
      {
         "compact": {
            "Desc": "If true then the parsed tree will push all data to the lowest level <u>boolean</u>. "
         }
      }
   ],
   "Examples": [
      "<pre>local Msg = hl7.zsegment.parse{data=Data, compact=false}</pre>"
   ],
   "ParameterTable": true
}]]

help.set{input_function=hl7.zsegment.parse, help_data=json.parse{data=HELP_DEF}}   

