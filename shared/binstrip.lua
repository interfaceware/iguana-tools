local bin = {}

function bin.strip( str )
   return str:gsub("[\128-\255]", "")
end
 

return bin