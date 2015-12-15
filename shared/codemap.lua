-- This code map library has a number of useful helper routines for doing mapping and checking codes etc.
 
local codemap = {}
 
-- Make a set
-- MySet = codemap.set{"Fred", "Bruce", "Jim"}
-- if MySet[Msg.PID[3][1][1]] then print('One of our three amigos') end
function codemap.set(a)
   local m = {}
   for _,v in ipairs(a) do m[v] = true end
   return codemap.map(m, false)
end
 
-- Create a map the advantage of this function is that it will take a tree node without
-- needing to convert it to a string.  Example of usage
-- SexMap = codemap.map({'M'='Male', 'm'='Male', 'F'='Female', 'f'='Female'},'defaultValue')
function codemap.map(m, default)
   return setmetatable(m, {
         __index = function(m,k)
            if type(k) ~= 'string' then
               local v = rawget(m, tostring(k))
               if v ~= nil then return v end
            end
            return default
         end})
end
 
return codemap