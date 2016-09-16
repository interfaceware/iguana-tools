-- See http://help.interfaceware.com/v6/log_annotate 

-- This module replaces the "print" and iguana.logInfo, iguana.logWarning etc. functions with replacements
-- which give a prefix about which type of translator project is being logged in

-- We use this local helper function to work out what translator type this is.
local function Prefix()
   -- 1) We fetch the XML for the configuration of the channel
   local X = xml.parse{data=iguana.channelConfig{guid=iguana.channelGuid()}}
   -- 2) We fetch the GUID of this translator project
   local Guid = iguana.project.guid()
   -- 3) Then we go check for the 5 different types of translators and compare
   --    which one corresponds to this translator instance - this allows us to
   --    get the type of translator and use that to make a prefix for each log statement 
   if X.channel.from_http         and X.channel.from_http.guid:S()                 == Guid then return "HTTP:"   end
   if X.channel.message_filter    and X.channel.message_filter.translator_guid:S() == Guid then return "Filter:" end
   if X.channel.to_mapper         and X.channel.to_mapper.guid:S()                 == Guid then return "To:"     end
   if X.channel.from_mapper       and X.channel.from_mapper.guid:S()               == Guid then return "From:"   end
   if X.channel.from_llp_listener and X.channel.from_llp_listener.ack_script:S()   == Guid then return "Ack:"    end
   return "Unknown"
end

local TranslatorPrefix = Prefix().." "

local OldPrint = print
function print(...)
   trace(arg)
   local Text = TranslatorPrefix
       ..table.concat(arg)
   trace(Text)
   OldPrint(Text)
end

local OldDebug = iguana.logDebug
function iguana.logDebug(Text, MessageId)
   trace(TranslatorPrefix..Text)
   if MessageId then OldDebug(TranslatorPrefix..Text, MessageId) else OldDebug(TranslatorPrefix..Text) end
end

local OldInfo = iguana.logInfo
function iguana.logInfo(Text, MessageId)
   trace(TranslatorPrefix..Text)
   if MessageId then OldInfo(TranslatorPrefix..Text, MessageId) else OldInfo(TranslatorPrefix..Text) end
end

local OldWarning = iguana.logWarning
function iguana.logWarning(Text, MessageId)
   trace(TranslatorPrefix..Text)
   if MessageId then OldWarning(TranslatorPrefix..Text, MessageId) else OldWarning(TranslatorPrefix..Text) end
end

local OldError = iguana.logError
function iguana.logError(Text, MessageId)
   trace(TranslatorPrefix..Text)
   if MessageId then OldError(TranslatorPrefix..Text, MessageId) else OldError(TranslatorPrefix..Text) end
end