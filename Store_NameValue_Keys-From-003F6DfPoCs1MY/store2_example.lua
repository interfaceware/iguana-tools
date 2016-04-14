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
   
   -- We can also put binary data into stores
   local BinData = 'Binary data\000Man\000'
   LocalChannelStore:put("Binary", BinData)
   local RetrievedBinData = LocalChannelStore:get("Binary")
   assert(BinData == RetrievedBinData)
   
   -- We can put numbers in - but they will be returned as strings
   LocalChannelStore:put("Number", 2323)
   local Number = LocalChannelStore:get("Number")
   
   -- To delete keys please use put with nil
   LocalChannelStore:put("Number", nil)
   LocalChannelStore:get("Number")
   
   -- We can reset stores which clears them
   trace(#MyStore:info())
   MyStore:reset()
   trace(#MyStore:info())
   -- Or we can delete them entirely.
   -- os.fs.stat allows us to test for the existance of the
   -- underlying database file.
   local DbFile = iguana.workingDir()..MyStore.name
   os.fs.stat(DbFile)
   -- Store2 can also handle *LARGE* values of 20 megs or so
   local LargeValue = 'Big file etc etc\n'
   LargeValue = LargeValue:rep(1000000)
   MyStore:put('Big/Life',LargeValue)
   MyStore:put('Big/Life', nil)
   MyStore:get('Big/Life')
   MyStore:put('Big/Life',LargeValue)
   local RestoredLargeValue = MyStore:get('Big/Life')
   assert(LargeValue==RestoredLargeValue)
   trace(#LargeValue)
   
   MyStore:delete()
   os.fs.stat(DbFile)
   LocalChannelStore:delete()
end
