function string.formatText(s, M, RS)
   local function lengthofWord(word)
      if word == '\n' or word == '\r' or word == '\t' then return #word + 1 end
      return #word
   end
   local function RSindex(i)
      if (#tostring(RS[i])) > (M - countOfWord - 2) then return i+1  end    
      return i
   end
   local i, position = 1, 0
   RS = {[1]=''} 
   for word in s:rxmatch('(\\w+.|\\s)') do
      countOfWord = lengthofWord(word)
      i = RSindex(i) 
      if RS[i] == nil then RS[i] = '' end
      RS[i] = RS[i]..word 
   end
   return RS
end
