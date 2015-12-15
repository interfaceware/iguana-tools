-- This module goes into the hl7 namespace
require 'hl7.serialize'

-- The module allows us to tightly control what delimiters and escape sequences are used to encode an HL7 message
-- See http://help.interfaceware.com/code/details/hl7-serialize-lua for more information.

function main(Data)
   Msg = hl7.parse{vmd='demo.vmd', data=Data}
   
   hl7.serialize{data=Msg}
 
   hl7.serialize{data=Msg, 
      delimiters = {'\n', '#', '.', '&', '\'', '*'}}
 
   hl7.serialize{data=Msg, 
      escaped = {'A', 'B', 'C', 'D', 'E'}}
   
   hl7.serialize{data = Msg, 
      delimiters = {'\n', '&', '\\', '}', '~', '^'},
      escaped = {'A', 'B', 'C', 'D', 'E'}}
   
   hl7.serialize{data = Msg, 
      delimiters = {'A', '|', '^', '~', '\\', '&'}}
end