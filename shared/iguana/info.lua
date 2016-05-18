-- This module returns the build information for the Iguana instance. 
-- This includes the operating system, CPU bit size and Iguana version

-- http://help.interfaceware.com/v6/iguana-info 

function iguana.info()
   local VI = iguana.version()
   local V={major=VI.major, minor=VI.minor, build=VI.build}
   local S = iguana.status()   
   for K in S:gmatch('VersionBuildId="([^"]*)"') do
      trace(K)
      
      V.cpu = 'unknown'
      V.os = 'unknown'
      if K:find("win") then
         V.os = "windows"
         if K:sub(-2) == '64' then
            V.cpu = '64bit'
         else
            V.cpu = '32bit'
         end
      elseif K:sub(1,3) == 'mac' then
         V.os = "osx"
         -- Iguana on Mac is 64 bit
         V.cpu = '64bit'
      elseif K:find("centos") or K:find("ubuntu") then
         V.os = "linux"
         if K:find("x64") then
            V.cpu = '64bit'
         else
            V.cpu = '32bit'   
         end
      end
   end
   return V
end

local helpInfo=[[{
   "Desc": "Get the build information for this Iguana instance. This includes the operating system, CPU bit size and Iguana version",
   "Returns": [
         {"Desc": "A table containing the Iguana Build Information <u>table</u>."}
   ],
   "SummaryLine": "Get the build information for this Iguana instance",
   "SeeAlso": [
   ],
   "Title": "iguana.info",
   "Usage": "iguana.info()",
   "Examples": [
      "<pre>local Info = iguana.info()</pre>"
   ],
   "ParameterTable": false,
   "Parameters": [],
   "SeeAlso":[
      {
         "Title":"iguana.info.lua on github",
         "Link":"https://github.com/interfaceware/iguana-tools/blob/master/shared/iguana/info.lua"
      },
      {
         "Title":"Iguana Info",
         "Link":"http://help.interfaceware.com/v6/iguana-info"
      }
   ]
}]]

help.set{input_function=iguana.info, help_data=json.parse{data=helpInfo}}    
