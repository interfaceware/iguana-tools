-- The retry module is very handy for handling situations where it makes
-- sense to retry failed operations.

-- http://help.interfaceware.com/v6/retry-example

-- Not all errors are equal.
-- Some errors represent transient environmental conditions - say a database is unavailable
-- you would just want to retry and continue.  Other errors might be fatal and require stopping
-- the interface and having a system administrator intervene.  The rety module allows one to
-- deal with all these situations.  I suggest reading:
--
-- http://help.interfaceware.com/v6/thinking-through-interface-error-handling

local retry = require 'retry'

math.randomseed(os.ts.time() % 1000)

-- We simulate intermittent errors - both fatal and non fatal.
local function UnreliableFunc(Data)
   if math.random(8) == 1 then
      error("We have a intermittent non fatal error!")
   end
   if math.random(10) == 1 then
      -- We have a fatal error for which we want the channel to stop
      -- We will pick this up in the ErrorFunction.
      -- We throw a table object for the error
      error({code=0, message='Critical database error.  Manual intervention required.'})
   end
   iguana.logInfo("Message handled fine.")
   return true
end

local function ErrorFunction(Success, ErrorMessage)
   if Success then
      iguana.logInfo("The function succeeded!")
   else
      if (type(ErrorMessage) == "table") then
         -- In this case we have an error message that does not make sense to retry
         iguana.logError(ErrorMessage.message);
         error("Stop the channel - fatal error!  Don't retry.");
      end
      iguana.logInfo("We had a boo boo: "..ErrorMessage)
      return Success
   end
   return Success
end

function main(Data)
   iguana.stopOnError(true)
   retry.call{func=UnreliableFunc,retry=20, pause=1, arg1=Data,
             funcname='UnreliableFunc', errorfunc=ErrorFunction}
end