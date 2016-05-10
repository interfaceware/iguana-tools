-- Simple routine to convert a table grammar into a JSON representation.

local function TraverseTable(R, T)
   if #T == 0 then return end
   local Def = {}
   R[T:nodeName()] = Def 
   local Cols = {}
   for i=1, #T[1] do 
      Cols[i] = T[1][i]:nodeName()
   end
   local Data = {}
   for i = 1, #T do 
      local Row = {}
      Data[i] = Row
      for j= 1, #T[i] do 
        Row[j] = T[i][j]:nodeValue()
      end
   end
   Def.columns = Cols
   Def.data = Data
   return
end

local function ToJson(T) 
   local R = {}
   for i=1, #T do
      R[T[i]:nodeName()] = {}
      TraverseTable(R, T[i])
   end
   
   return json.serialize{data=R}
end

return ToJson