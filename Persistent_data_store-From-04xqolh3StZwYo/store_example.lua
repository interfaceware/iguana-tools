-- This is the original store module. It retains the original interface
-- for 100% backward compatability.  
-- A lot of interfaces have been written using this module so we maintain
-- it out of respect for our customers. For new interfaces we recommend
-- the store2 module which has the ability to allow one translator instance
-- have multiple stores.

-- Under the hood this module creates a SQLite database by default called ‘store.db’ in the Iguana working directory. 
-- This has a table called “store”, which has the name=value pairs. However you don’t need to know this, 
-- just create a store module (using the code above) and it will all work automatically.

-- It is good practice to use the store.init function. This function changes the store module to use another database
-- file instead of the default one. This is valuable when you have multiple channels using the store module and you want
-- to guarantee independence or you want the freedom to clear the store. The store2 module is even better in this regard.

-- http://help.interfaceware.com/v6/store-example

local store = require 'store'

local function ShowStore()
   -- It's best practice to use the init function to
   -- create different name spaces for different uses of
   -- the store module. This prevents one use of the store
   -- module in one channel interfering with another.
   store.init('mystore.db')
   store.resetTableState()
   local Message = "Using: "..iguana.workingDir()..store.name()
   trace(Message)
   
   -- Store a value
   store.put('Iguana', 'awesome')
 
   -- Get a value
   local Value = store.get('Iguana')
   trace('Iguana is '..Value)
   
   -- Clear the store
   store.resetTableState()
   -- Now the Iguana value will be nil
   trace(store.get('Iguana'))
end

return ShowStore