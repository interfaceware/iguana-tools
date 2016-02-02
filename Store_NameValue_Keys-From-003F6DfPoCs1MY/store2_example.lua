-- This is the new version of store which allows one translator to have multiple stores
-- iNTERFACEWARE recommends this for newer interface code.  It is convenient to be able to
-- have independent stores for different purposes.

-- This module stores the data in SQLite data base file given in the store2.connect function.
-- By default this goes into the working directory of the Iguana instance.

store2 = require 'store2'

function ShowStore2()
   local MyStore = store2.connect("store2.db")
   MyStore:put("life", "can be fun")
   MyStore:get("life")
   -- Query all the stored keys
   MyStore:info()
      
   -- Here we create a store which is unique to this translator
   -- by naming it after the GUID of this translator.
   local LocalChannelStore = store2.connect(iguana.project.guid())   
   LocalChannelStore:put("life", "can be interesting")
   
   -- See two independent stores?
   LocalChannelStore:get("life")
   MyStore:get("life")
   
   -- We can reset stores which clears them
   trace(#MyStore:info())
   MyStore:reset()
   trace(#MyStore:info())
   -- Or we can delete them entirely.
   -- os.fs.stat allows us to test for the existance of the
   -- underlying database file.
   local DbFile = iguana.workingDir()..MyStore.name
   os.fs.stat(DbFile)
   MyStore:delete()
   os.fs.stat(DbFile)
   LocalChannelStore:delete()
end