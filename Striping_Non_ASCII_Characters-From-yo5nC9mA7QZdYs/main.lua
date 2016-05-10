local BinaryStrip = require 'binstrip'

-- Sometimes you need to remove characters that have a value of 128 or above.  This module does this.

function main()
   local BadString = "This is Fred who has some\244\135 issues."
   trace(BadString)
   local GoodString = BinaryStrip(BadString)
   trace(GoodString)
end