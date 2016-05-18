-- Sometimes you need to remove unprintable characters that have a 
-- an ascii value of 128 or above. This module does this.

-- http://help.interfaceware.com/v6/strip-unprintable-characters 

Strip = require 'bin.strip'

function main()
	-- sting contains uprintable characters
   local BadString = "This is Fred who has some\244\135 issues."
   trace(BadString)
   
   -- strip any unprintable characters
   local GoodString = Strip(BadString)
   trace(GoodString)
end