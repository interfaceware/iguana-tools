-- The store MK II module
-- Copyright (c) 2016 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in accordance
-- with the terms of the iNTERFACEWARE license agreement accompanying the software
-- in which it is used.
--
-- This new version of the store module involves constructing a store with the name of the store table.
--
-- http://help.interfaceware.com/v6/store-example

local store = {}

-- Constants.
local DROP_TABLE_COMMAND = "DROP TABLE IF EXISTS store"
local CREATE_TABLE_COMMAND = [[
CREATE TABLE store(
CKey Text(255) NOT NULL PRIMARY KEY,
CValue Blob 
)]]

local method = {}
local MT = {__index = method}


local function GetConnection(Name)
   local Connection = db.connect{api=db.SQLITE, name=Name}
   return Connection
end

-- Connect to the store and initialize if necessary  
function store.connect(Name)
   local Store = {}
   setmetatable(Store, MT)
   Store.name = Name
   local conn = GetConnection(Name)
   local R = conn:query('SELECT * from sqlite_master WHERE type="table" and tbl_name="store"')
   trace(#R)
   if #R == 0 then
      conn:begin()
      conn:execute{sql=DROP_TABLE_COMMAND, live=true}
      conn:execute{sql=CREATE_TABLE_COMMAND, live=true}
      conn:commit()
   end
   conn:close()
   return Store
end

-- Methods
 
-- This function returns the state of the store table by performing a general select query on it.
function method:info()
   local conn = GetConnection(self.name)
   local R = conn:query ("SELECT * FROM store")
   conn:close()
   return R
end

local function BlobFileName(Store, Key)
   return "blob_"..Store.name..'/'..filter.uri.enc(Key)
end

local BlobMajikString = ".213djjdejJJdsmsd.d"

local function BlobStoreDir(Store)
   return "blob_"..Store.name
end

local function WriteBlob(Store, Key, Value)
   local StoreDir = BlobStoreDir(Store)
   if not os.fs.stat(StoreDir) then
      os.fs.mkdir(StoreDir, 700)
   end
   local FileName = BlobFileName(Store, Key)
   local F = io.open(FileName, "wb")
   F:write(Value)
   F:close()
end

local function ReadBlob(Store, Key)
   local FileName = BlobFileName(Store,Key)
   local F = io.open(FileName, "rb")
   if not F then return nil end
   local C = F:read("*a")
   F:close()
   return C
end

local function ClearBlobs(Store)
   local Dir = BlobStoreDir(Store)
   if not os.fs.stat(Dir) then
      return
   end
   for K,V in os.fs.glob(Dir..'/*') do
      os.remove(K)
   end
   os.fs.rmdir(Dir)
end

-- This function resets the state of the store table by first deleting it and then recreating it.
function method:reset()
   -- This operation is performed as a database transaction to prevent another
   -- Translator script from accidentally attempting to access the store table
   -- while it has been temporarily deleted.
   local conn = GetConnection(self.name)
   conn:begin()
   conn:execute{sql=DROP_TABLE_COMMAND, live=true}
   conn:execute{sql=CREATE_TABLE_COMMAND, live=true}
   conn:commit()
   conn:close()
   ClearBlobs(self)
end

-- This function will completely delete the underlying store

function method:delete()
   if os.fs.stat(self.name) then
      os.remove(self.name)
   end
   ClearBlobs(self)
end


function method:put(Key, Value)
   local conn = GetConnection(self.name)
   if (not Value) then
      -- Clearing the value - it's possible there might have been a blob
      local FileName = BlobFileName(self,Key)
      os.remove(FileName)
      local Sql = "DELETE FROM store WHERE CKey = "..conn:quote(tostring(Key))
      conn:query{sql=Sql}
      conn:close()
      return "Cleared key "..Key
   end
   
   if #tostring(Value) > 100000 then
      WriteBlob(self, Key, Value)
      local R = conn:query('REPLACE INTO store(CKey, CValue) VALUES(' ..
      conn:quote(tostring(Key)) .. ",'"..BlobMajikString.."')")
      conn:close()
      return
   end
   
   
   local R = conn:query('REPLACE INTO store(CKey, CValue) VALUES(' ..
      conn:quote(tostring(Key)) .. ",x'" .. filter.hex.enc(tostring(Value)) .. "')")
   conn:close()
end
 
function method:get(Key)
   local conn = GetConnection(self.name)
   local R = conn:query('SELECT CValue FROM store WHERE CKey = ' .. conn:quote(tostring(Key)))
   conn:close()
   
   if #R == 0 then
      return nil
   end
   if R[1].CValue:nodeValue() == BlobMajikString then
      return ReadBlob(self, Key)
   end
   
   return R[1].CValue:nodeValue()
end
 
-- help for the functions

if help then
   ------------------------
   -- store:info()
   ------------------------
   local h = help.example()
   h.Title = 'store:info()'
   h.Desc = 'Return the state of the store table, by selecting all the rows.'
   h.Usage = 'store:info()'
   h.Parameters = ''
   h.Returns = {[1]={['Desc']='All the rows from the store table <u>result set node tree</u>'}}
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>
      -- check the state of the store table, if more than 1 row then empty the store
      if  #store:info() > 1 then
         store:reset()
      end
      </pre>]]}
   h.SeeAlso = ''
   help.set{input_function=method.info, help_data=h}
 
   --------------------------
   -- store:reset()
   --------------------------
   local h = help.example()
   h.Title = 'store:reset'
   h.Desc = 'Reset the state of the store table, by deleting and recreating the table.'
   h.Usage = 'store:reset()'
   h.Parameters = ''
   h.Returns = 'none.'
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>
      -- reset the store table if more than 1 row exists
      if  #store:info() > 1 then
         store:reset()
      end
      </pre>]]}
   h.SeeAlso = ''
   help.set{input_function=method.reset, help_data=h}
 
   --------------------------
   -- store:delete()
   --------------------------
   local h = help.example()
   h.Title = 'store:delete'
   h.Desc = 'Delete store database file entirely.'
   h.Usage = 'store:delete()'
   h.Parameters = ''
   h.Returns = 'none.'
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>store:delete()</pre>]]}
   h.SeeAlso = ''
   help.set{input_function=method.delete, help_data=h} 
   
   ------------------------
   -- store:put()
   ------------------------
   local h = help.example()
   h.Title = 'store:put(Name, Value)'
   h.Desc = [[Insert a Value for the Key. If the Key exists then replace the value. 
              If the Key does not exist insert a new Key and Value.  Setting the Value equal to nil
              will result in the Key being deleted from the store.]]
   h.Usage = 'store:put(Key, Value)'
   h.Parameters = {
      [1]={['Key']={['Desc']='Unique Identifier <u>string</u>'}},
      [2]={['Value']={['Desc']='Value to store <u>string</u>'}}
   }
   h.Returns = {[1]={['Desc']='Message confirming deletion or nil <u>string</u>'}}
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>store:put('I am the Key', 'I am the Value')</pre>]]}
   h.SeeAlso = ''
   help.set{input_function=method.put, help_data=h}
 
   ------------------------
   -- store:get()
   ------------------------
   local h = help.example()
   h.Title = 'store:get(Name)'
   h.Desc = 'Retrieve the Value for the specified Key. If the Key is not found nil is returned'
   h.Usage = 'store:get(Key)'
   h.Parameters = {
      [1]={['Key']={['Desc']='Unique Identifier <u>string</u>'}}
   }
   h.Returns = {[1]={['Desc']='The Value of the row specified by the Key <u>string</u>'}}
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>store:get('I am the Key')</pre>]]}
   h.SeeAlso = ''
   help.set{input_function=method.get, help_data=h}
   
   ------------------------
   -- store.connect()
   ------------------------
   local h = help.example()
   h.Title = 'store.connect(DatabaseName)'
   h.Desc = 'Connect to store with the name of the SQLite data base to be used for the store.'
   h.Usage = 'store.connect(DatabaseName)'
   h.Parameters = {
      [1]={['DatabaseName']={['Desc']='Name of the database file <u>string</u>'}}
   }
   h.Returns = {[1]={['Desc']='A store object with methods to access the data <u>table</u>'}}
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>local MyStore = store.store("mystore.db")</pre>
               MyStore:put("id", 1212)]]}
   h.SeeAlso = ''
   help.set{input_function=store.connect, help_data=h}
end

return store