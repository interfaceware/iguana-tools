-- This example shows how to load files that are in a project
-- for a translator instance.
-- The technique is simply to understand the layout of the file system
-- and use standard Lua file APIs to load the files in question

-- http://help.interfaceware.com/v6/read-project-file-from-lua

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

   -- Let's load the 'local.xml' file
   local LocalXml = loadFile(FilePath..'local.xml')
   -- For fun let's parse the xml
   local X = xml.parse{data=LocalXml}

   -- Getting to the 'other' directory is also easy 
   -- Let's load the 'example.xml' file from the 'other' directory
   local OtherXml = loadFile(iguana.project.root()..'other/example.xml')
   X = xml.parse{data=OtherXml}
   trace(X)

   -- You can of course load any file in the same way
   -- for example a Lua file
   local MainFile = loadFile(FilePath..'main.lua')
   trace(MainFile)
   
   iguana.logInfo("Local.xml:\n\n"..LocalXml.."\n\nOther XML:\n\n"
      ..OtherXml.."\n\nAnd we can log what is in main.lua too:\n\n"..MainFile.."\n\n")
end