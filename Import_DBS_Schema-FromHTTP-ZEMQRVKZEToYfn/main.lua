-- This channel shows the use of a module which gives a very convenient
-- API over the top of the DBS grammar schema.
--
-- It allows one to write code which can create a schema on the fly or
-- query one of number of databases to generate the schema.

-- DBS schema perform the same role as a vmd based table grammar
-- in allowing one to populate a set of records and use the db:merge{} function.
-- See http://help.interfaceware.com/api/#dbs_init
-- As of today the supported databases are:
-- * MySQL and MariaDB
-- * Microsoft SQL Server
-- * Oracle
-- * SQLite
-- It's relatively trivial to add support for other databases - if you need help adding support
-- for another database type please reach out.

-- http://help.interfaceware.com/v6/import-database-schema

local NewSchema = require 'dbs.api'

local config = require 'encrypt.password'
local Key = 'sdlfjhslkfdjhslkdfjhskj'

-- Follow these steps to store database credentials securely in 4 configuration files
-- This method is much more secure than saving database credentials in the Lua script
-- NOTE: (step 4) Be careful not to save a milestone containing password information
-- See http://help.interfaceware.com/v6/encrypt-password-in-file
-- To change the database name, user, password and database API type you'll need to 
--  1) Enter them into these lines
--  2) Uncomment the lines.
--  3) Recomment the lines
--  4) Remove the password and host from the file before you same a milestone

--config.save{config='appname',     key=Key, password='Replace with your database name'}
--config.save{config='apppassword', key=Key, password='Replace with your database password'}
--config.save{config='appuser',     key=Key, password='Replace with your database user'}
--config.save{config='appapi',      key=Key, password=tostring(db.SQLITE)} -- Replace with your API TYPE

local function GetSchema()
   local Password = config.load{config='apppassword', key=Key}
   local DbName   = config.load{config='appname', key=Key}
   local DbUser   = config.load{config='appuser', key=Key}
   local DBApi    = tonumber(config.load{config='appapi', key=Key})
   local DB = db.connect{
      api=DBApi, 
      user=DbUser, 
      password=Password,
      name=DbName
   }
   local Schema = NewSchema()
   trace(Schema)
   Schema:import{connection=DB}  
   local Def = Schema:dbs{}
   local D = dbs.init{definition=Def}
   local A = D:tables()
   -- 5) Try examining A
   
   -- We can clear the schema
   Schema:clear{}
   return Def
end

local ErrorMessage 

function main()
   local Success, Schema
   if iguana.isTest() then
      Success = true
      Schema = GetSchema()
   else
      Success, Schema = pcall(GetSchema)    
   end
   if Success then
      net.http.respond{body=Schema, entity_type='text/plain'}
   else
      if type(Schema)=='table' then
         Schema = Schema.message
      end
      net.http.respond{body=ErrorMessage:gsub("#ERROR#", Schema), entity_type='text/html'}
   end
end


ErrorMessage = [[
<p>
Failed to connect and generate schema.  You probably have not edited
the channel yet to put in the right database credentials.  Please read
the <a href="http://help.interfaceware.com/v6/import-database-schema">instructions here</a>.
</p>
<p>
Basically you'll need to:
</p>
<ol>
<li>Stop the channel</li>
<li>Edit the source code to put in the right credentials for your database</li>
<li>Rerun the channel.</li>
</ol>
<p>
Error message is:
</p>
<pre>
#ERROR#
</pre>
]]
