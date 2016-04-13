-- This xml module provides a few extra helpful little utility functions
-- http://help.interfaceware.com/v6/xml-channel

require 'xml'

-- This project shows a whole suite a techniques which are handy when dealing with
-- XML - in this case mapping to an HL7 message.

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
   
   ManipulateXML(X)
   trace(Msg)
   trace(Msg:S())
end

-- These functions illustrate the utility of the xml module.
function ManipulateXML(X)
   -- Add an element
   X.message:addElement("extra_info")
   -- Let's set an attribute on that new elemement
   X.message.extra_info:setAttr("message_id", iguana.messageId())
   trace(X.message)
   
   -- For more control over where the element gets
   -- inserted
   X.message:insert(1, xml.ELEMENT, 'first')
   X.message.first:setText("Notice this goes first")
   X.message.first:setAttr("fun", "withxml")
   trace(X.message)
end