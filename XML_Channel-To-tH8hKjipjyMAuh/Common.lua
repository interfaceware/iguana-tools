-- We use some helpful extra string processing functions
require 'stringutil'

-- Common routine mapping patient

function MapPatient(PID, X)
   PID[2][1]= X.id
   
   -- We get the name using the :text() helper - this ensures
   -- the code will work even if the text between the tags is
   -- empty.  We convert the 'node' to a string so we can use
   -- the split function
   local FullName = X.name:text():S()
   
   -- Get rid of multiple white space
   FullName = FullName:compactWS()
   -- Get rid of leading and trailing whitespace
   FullName = FullName:trimWS()
   -- Now we split the field and hope optimistically that is
   -- is indeed FirstName LastName (hopefully your real data
   -- is not this loosely formed!)
   local NameArray = FullName:split(' ')
   PID[5][1][1][1] = NameArray[2]
   PID[5][1][2] = NameArray[1]
   
   ProcessPhone(PID, X)   
end

function ProcessPhone(PID, X)
   -- Now we show another technique of dealing with XML
   -- looping through a collection
   for i=1, X:childCount("phone") do
      local Phone = X:child("phone", i)
      -- In case the phone text is not there we use this
      -- helper function
      local Number = Phone:text()
      if Phone.type:S() == "home" then
         -- In case the phone number is empty
         PID[13][1][1] = Number
      elseif Phone.type:S() == 'work' then
         PID[14][1][1] = Number
      end
   end   
end