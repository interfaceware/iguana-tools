-- See http://help.interfaceware.com/v6/log_annotate 
-- This example channel uses the log.annotate module to change
-- the built in behavior of the logging commands to prefix the
-- log statements with the translator type that generated the log.

-- To try it out, run the channel and connect to it's URL and then
-- go look at the logs.

require 'log.annotate'

-- Make a URL which can open up the logs.
local function LogUrl(ChannelName)
   local WebInfo = iguana.webInfo()
   local Url = "http"
   if WebInfo.web_config.use_https then
      Url = Url.."s"
   end
   Url = Url.."://"
   Url = Url..WebInfo.host
   Url = Url..":"..WebInfo.web_config.port
   Url = Url.."/logs.html?Source="..filter.uri.enc(ChannelName)
   Url = Url.."&Deleted=both&Export.Format=Plain"
   return Url
end

function main(Data)
   iguana.logInfo("We got a web request\n"..Data)
   queue.push{data="A message"}
   
   local Url = LogUrl(iguana.channelName())
   
   net.http.respond{body="<a href='"..Url..
     "'>Click here to see the logs for this channel.</a>"}
end