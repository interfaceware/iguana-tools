-- This is a trivial example of calling a web service and serving up the data.
-- In this case we go and get the weather in London off the openweather map 
-- web service.

-- A prompt to people to read the code.
local Info = " Now read the code of this channel."

function main(Data)
   -- We call the open weather service
   local Url = 'http://api.openweathermap.org/data/2.5/weather'
   -- Find out the weather in London, UK
   local Parameters = {
      q='London,uk', 
      appid='6c33b91b0582d178d85ad63b7fb2ea7f'
   }
   
   -- Call the web service
   local Result = net.http.get{url=Url, parameters=Parameters, live=true}
   -- Parse the JSON data we got back
   local D = json.parse{data=Result}
   
   -- Format a trivial rendering of the data
   local Body = "Weather in London: <b>"..D.weather[1].description.."</b>."
   trace(Body)
   -- And put it into the web page result.
   net.http.respond{body=Body..Info}
   -- DONE!
end

