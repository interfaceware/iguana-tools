-- This channel shows another usage of the dbs.api
-- The dbs.api offers a convenient interface from which
-- to programmatically create tables and add columns to them.

-- Why is this useful?

-- Well my motivation was to in order to make better web
-- adapters.  Because this module allows me to create DBS
-- schema on the fly it was useful to making a nicer adapter.

-- I could put salesforce.com data into the table objects and
-- use the objects to create records in the salesforce.com
-- application.  This is nice because the annotations are really
-- nice for these types of table like objects.

-- http://help.interfaceware.com/v6/manipulate-database-schema

local ToJson = require 'ToJson'

local NewSchema = require 'dbs.api'

function main(Data)
   local Schema = NewSchema()
   -- Create a 'Contact' table.
   local T = Schema:table{name="Contact"}
   T:addColumn{name="id",        type=dbs.integer,key=true}
   T:addColumn{name="FirstName", type=dbs.string}
   T:addColumn{name="LastName" , type=dbs.string}
   T:addColumn{name="Title"    , type=dbs.string}
  
   -- Create an 'Invoice' table.
   local T = Schema:table{name="Invoice"}
   T:addColumn{name="Id",     type=dbs.integer, key=true}
   T:addColumn{name="Name",   type=dbs.string}
   T:addColumn{name="Amount", type=dbs.double} 
   
   local T = Schema:table{name="Account"}
   T:addColumn{name="Id",     type=dbs.double, key=true}
   T:addColumn{name="Name",   type=dbs.string}
   T:addColumn{name="Street", type=dbs.string}
   
   -- We can create groups of tables.
   Schema:addGroup{name="Financial", table_list={"Invoice", "Account"}}
   
   local CS = dbs.init{definition=Schema:dbs{}}
   -- Create instance with all tables.
   local D = CS:tables()
   D.Invoice[1].Id = 111
   D.Contact[1].FirstName = "Harold"
   D.Contact[1].LastName  = "Smith"
   D.Invoice[1].Name      = "Cleaning bill"
   D.Invoice[1].Amount    = 2323.33
   D.Account[1].Id = 11
   D.Account[1].Name = "CIBC"
   D.Account[1].Street = "Main Street"
   D.Account[2].Id = 12
   D.Account[2].Name = "TD"
   D.Account[2].Street = "121 Life Lane"
   
   trace(D)
   -- The next routine shows how we can package up the data into a
   -- JSON object of an arbitrary format
   local Body = ToJson(D)
   -- We can also instantiate the Financial group of tables.
   local F = CS:tables("Financial")
   F.Invoice[1].Id = 100
   F.Invoice[1].Name = "McDonalds"
   F.Account[1].Name = "Acme Enterprises"
   trace(F)
   -- And convert it into JSON.
   ToJson(F)
   
   net.http.respond{body=Body, entity_type='text/json'}
end
