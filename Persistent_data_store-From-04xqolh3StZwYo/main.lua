-- The store.lua module contains a simple interface to store key/value pairs in a persistent storage
-- mechanism. Simply put, if you want to store and/or retrieve information across interfaces cross-message;
-- this is a useful module to do it.

-- There are two version of this module. The store module was the original one.
-- The store2 module was created later. It has the advantage of enabling one to use
-- multiple store instances in a single translator script.  New code should use the
-- the store2 module.

-- http://help.interfaceware.com/v6/store-example

local ShowStore = require 'store_example'
local ShowStore2 = require 'store2_example'

function main()
   ShowStore()
   ShowStore2()
end


