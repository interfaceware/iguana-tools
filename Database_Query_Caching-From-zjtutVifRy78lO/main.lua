db.cache         = require 'db.querycache'
local SQLITEDB   = iguana.project.root() .. 'other/dbCacheExample.db'
local CONN       = db.connect{api=db.SQLITE,name=SQLITEDB,user='',password=''}

function main()
   -- Query for a random user with an ID between 1 and 21,
   -- return 0 if no results, cache this value for 20 seconds
   local rset = db.cache.query{
      sql     = 'SELECT * FROM Users WHERE USERID=#VALUE#',
      db      = CONN,
      value   = math.random(1,21),
      default = 0,
      max_age = 20
   }
   
   -- Query for a random user with an ID between 1 and 21,
   -- return the default value of false if no results,
   -- cache this value for the default 1 hour
   local rset = db.cache.query{
      sql   = 'SELECT * FROM Users WHERE USERID=#VALUE#',
      db    = CONN,
      value = math.random(1,21)
   }
   
   -- In this example we don't use any value substitution - simply
   -- select the whole table and cache the result for 5 seconds
   local rset = db.cache.query{
      sql     = 'SELECT * FROM Users',
      db      = CONN,
      max_age = 5
   }
   
   -- In these two examples we query for the same non-existing user.
   -- Even though the second line tries to cache the result for
   -- 20 seconds it has already been cached for 1 hour and won't
   -- be overwritten. The second example will return its custom
   -- default value.
   local rset = db.cache.query{
      sql   = 'SELECT * FROM Users WHERE USERID=#VALUE#',
      db    = CONN,
      value = 21
   }
   local rset = db.cache.query{
      sql     = 'SELECT * FROM Users WHERE USERID=#VALUE#',
      db      = CONN,
      value   = 21,
      default = 'n/a',
      max_age = 20
   }
   
   -- These functions can be useful for debugging
   --db.cache.list()  -- Returns the cache list and cache purge schedule
   --db.cache.clear() -- Empty the cache
end