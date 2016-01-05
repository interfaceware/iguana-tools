-- The main function is the first function called from Iguana.
-- This example shows how one can load files that are in a project file
-- for a translator instance.
-- The trick is just to understand the layout of the file system and then use
-- standard Lua file apis to load the files in question


function loadFile(FileName)
   local F = io.open(FileName, "r")
   local Content =  F:read('*a')
   F:close()
   return Content
end

function main()
   -- First let's get the path to the root directory of this project
   local FilePath = iguana.project.root()..iguana.project.guid()..'/'
   -- Here's the file path
   trace(FilePath)
   -- Let's load it
   local LocalXml = loadFile(FilePath..'local.xml')
   -- For fun let's parse the xml
   X = xml.parse{data=LocalXml}
   -- Getting to the 'other' directory is also easy 
   local OtherXml = loadFile(iguana.project.root()..'other/example.xml')
   X = xml.parse{data=OtherXml}
   trace(X)
   -- You can of course load Lua files as well...
   local MainFile = loadFile(FilePath..'main.lua')
   trace(MainFile)
   
   iguana.logInfo("Local.xml:\n\n"..LocalXml.."\n\nOther XML:\n\n"
      ..OtherXml.."\n\nAnd we can log what is in main.lua too:\n\n"..MainFile.."\n\n")
end