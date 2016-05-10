
local function BinaryStrip( str )
   return str:gsub("[\128-\255]", "")
end 

return BinaryStrip