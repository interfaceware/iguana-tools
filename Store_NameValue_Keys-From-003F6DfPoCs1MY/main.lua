-- http://help.interfaceware.com/code/details/store-lua
-- The store.lua module contains a simple interface to store key/value pairs in a persistent storage
-- mechanism.  Simply put, if you want to store and/or retrieve information across interfaces cross-message;
-- this might be the module to do it.
-- Under the hood this module creates a SQLite database called ‘store.db’ in the Iguana working directory, 
-- which has a table called “store”, which has the name=value pairs. However you don’t need to know this, 
-- just create a store module (using the code above) and it will all work automatically.
store = require 'store'

function main()
   -- Store a value
   store.put('Iguana', 'awesome')
 
   -- Get a value
   local ifw = store.get('Iguana')
   trace('Iguana is ' .. ifw)
end