-- This xml module provides a few extra helpful little utility functions
-- See http://help.interfaceware.com/kb/xml-node-functions
require 'xml'

-- This project has some local extra modules.
require 'MapADT'
require 'MapLab'
require 'Common'

local EventMap = {lab='Lab', register='ADT'}

function main(Data)
   local X = xml.parse{data=Data}
   local EventType = X.message.event.type:S()
   
   local MsgName = EventMap[EventType]
   trace(MsgName)
   if not MsgName then
      error(MsgName.." is an unknown event!")
   end
   local Msg = hl7.message{vmd='demo.vmd', name=MsgName}
   
   -- This is one way of doing mapping different
   -- types to different functions
   if Msg:nodeName() == 'ADT' then
      MapADT(Msg, X)
   elseif Msg:nodeName() == 'Lab' then
      MapLab(Msg, X)
   end
   -- Another way is to use a table with functions
   -- this action table could be defined outside of main
   local ActionTable = {ADT=MapADT, Lab=MapLab}
   ActionTable[Msg:nodeName()](Msg, X)
end