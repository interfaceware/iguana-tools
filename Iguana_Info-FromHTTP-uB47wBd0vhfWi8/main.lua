-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
require 'iguana.info'

function main(Data)
   local Info = iguana.info()
   
   local Body = "Iguana version   : "..Info.major.."."..Info.minor.."."..Info.build.."\n"
   Body = Body.."Operating System : "..Info.os.."\n"
   Body = Body.."CPU Type         : "..Info.cpu.."\n"
   trace(Body)
   
   net.http.respond{body=Body, entity_type="text/plain"}
end