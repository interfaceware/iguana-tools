-- The stringutil module
-- Copyright (c) 2011-2016 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in accordance
-- with the terms of the iNTERFACEWARE license agreement accompanying the software
-- in which it is used.
-- http://help.interfaceware.com/code/details/stringutil-lua

-- stringutil contains a number of extensions to the standard Lua String library. 
-- As you can see writing extra methods that will work on strings is very easy. 
-- http://www.lua.org/manual/5.1/manual.html#5.4 for documentation on the Lua String library

-- This version of stringutil goes a little further in that it defines these operations
-- directly on node tree objects.  This is helpful if you are running a earlier version of Iguana.
-- 
-- From Iguana 6.0.3 we started to roll a lot of these functions into the core of Iguana itself - as
-- a result this version of stringutils does less than previous versions.

-- Trims white space on both sides.

-- http://help.interfaceware.com/v6/stringutil-string-functions

if not string.trimWS then
   string.trimWS = function (self)
      return self:match('^%s*(.-)%s*$')
   end
   local trimWS_help = {
      Title="string.trimWS";
      Usage="string.trimWS(string) or aString:trimWS()",
      SummaryLine="Trims white space from the start and the end of a string.",
      Desc=[[Trims white space from the start and the end of a string.
      ]];
      ["Returns"] = {
         {Desc="String after white spaces have been trimmed <u>string</u>."},
      };
      ParameterTable= false,
      Parameters= {
         {string= {Desc='String to trim spaces from <u>string</u>.'}},
      };
      Examples={
         [[   local S = '   trim spaces before and after   '
         S:trimWS()
         --> 'trim spaces before and after'

         string.trimWS('   trim spaces before and after   ') 
         --> 'trim spaces before and after'
         ]],
      };
      SeeAlso={
         {
            Title="Source code for the stringutil.lua module on github",
            Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/stringutil.lua"
         },
         {
            Title="String Manipulation Extensions",
            Link="http://help.interfaceware.com/v6/stringutil-string-functions"
         }
      }
   }

   help.set{input_function=string.trimWS, help_data=trimWS_help}
end

-- Trims white space on right side.
if not string.trimRWS then
   string.trimRWS = function(self)
      return self:match('^(.-)%s*$')
   end
   local trimRWS_help = {
      Title="string.trimRWS";
      Usage="string.trimRWS(string) or aString:trimRWS()",
      SummaryLine="Trims white space from the right of a string.",
      Desc=[[Trims white space from the right of a string.
      ]];
      ["Returns"] = {
         {Desc="String after white spaces have been trimmed <u>string</u>."},
      };
      ParameterTable= false,
      Parameters= {
         {string= {Desc='String to trim spaces from <u>string</u>.'}},
      };
      Examples={
         [[   local S = '   trim spaces from the right   '
         S:trimRWS()
         --> '   trim spaces from the right'

         string.trimRWS('   trim spaces from the right   ') 
         --> '   trim spaces from the right'
         ]],
      };
      SeeAlso={
         {
            Title="Source code for the stringutil.lua module on github",
            Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/stringutil.lua"
         },
         {
            Title="String Manipulation Extensions",
            Link="http://help.interfaceware.com/v6/stringutil-string-functions"
         }
      }
   }

   help.set{input_function=string.trimRWS, help_data=trimRWS_help}
end

-- Trims white space on left side.
if not string.trimLWS then
   string.trimLWS = function(self)
      return self:match('^%s*(.-)$')
   end
   local trimLWS_help = {
      Title="string.trimLWS";
      Usage="string.trimLWS(string) or aString:trimLWS()",
      SummaryLine="Trims white space from the left of a string.",
      Desc=[[Trims white space from the left of a string.
      ]];
      ["Returns"] = {
         {Desc="String after white spaces have been trimmed <u>string</u>."},
      };
      ParameterTable= false,
      Parameters= {
         {string= {Desc='String to trim spaces from <u>string</u>.'}},
      };
      Examples={
         [[   local S = '   trim spaces from the left   '
         S:trimLWS()
         --> 'trim spaces from the left   '

         string.trimLWS('   trim spaces from the left   ') 
         --> 'trim spaces from the left   '
         ]],
      };
      SeeAlso={
         {
            Title="Source code for the stringutil.lua module on github",
            Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/stringutil.lua"
         },
         {
            Title="String Manipulation Extensions",
            Link="http://help.interfaceware.com/v6/stringutil-string-functions"
         }
      }
   }

   help.set{input_function=string.trimLWS, help_data=trimLWS_help}
end

-- This routine will replace multiple spaces with single spaces 
if not string.compactWS then
   string.compactWS = function(self) 
      return self:gsub("%s+", " ") 
   end
   local compactWS_help = {
      Title="string.compactWS";
      Usage="string.compactWS(string) or aString:compactWS()",
      SummaryLine="Replace multiple spaces with a single space.",
      Desc=[[Replace multiple spaces in a string with a single space.
      ]];
      ["Returns"] = {
         {Desc="String after white spaces have been trimmed <u>string</u>."},
      };
      ParameterTable= false,
      Parameters= {
         {string= {Desc='String to trim spaces from <u>string</u>.'}},
      };
      Examples={
         [[   local S = '   replace    multiple   spaces   with  a  single  space   '
         S:compactWS()
         --> ' replace multiple spaces with a single space '

         string.compactWS('   replace    multiple   spaces   with  a  single  space   ') 
         --> ' replace multiple spaces with a single space '
         ]],
      };
      SeeAlso={
         {
            Title="Source code for the stringutil.lua module on github",
            Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/stringutil.lua"
         },
         {
            Title="String Manipulation Extensions",
            Link="http://help.interfaceware.com/v6/stringutil-string-functions"
         }
      }
   }
   help.set{input_function=string.compactWS, help_data=compactWS_help}
end

-- This routine capitalizes the first letter of the string
-- and returns the rest in lower characters
if not string.capitalize then
   string.capitalize = function(self)
      local R = self:sub(1,1):upper()..self:sub(2):lower()
      return R
   end

   local capitalize_help = {
      Title="string.capitalize";
      Usage="string.capitalize(string) or aString:capitalize()",
      SummaryLine="Capitalizes the first letter of a string",
      Desc=[[Capitalize the first letter of a string.
      ]];
      ["Returns"] = {
         {Desc="String after it it has been capitalized <u>string</u>."},
      };
      ParameterTable= false,
      Parameters= {
         {string= {Desc='String to be capitalized <u>string</u>.'}},
      };
      Examples={
         [[   local S = 'string to be capitalized'
         S:capitalize()
         --> 'String to be capitalized'

         string.capitalize('string to be capitalized') 
         --> 'String to be capitalized'
         ]],
      };
      SeeAlso={
         {
            Title="Source code for the stringutil.lua module on github",
            Link="https://github.com/interfaceware/iguana-tools/blob/master/shared/stringutil.lua"
         },
         {
            Title="String Manipulation Extensions",
            Link="http://help.interfaceware.com/v6/stringutil-string-functions"
         }
      }
   }
   help.set{input_function=string.capitalize, help_data=capitalize_help}
end

-- This helper function takes the name of a string function and makes an equivalent node function
-- If it can get the help then it gets that too.
local function MakeNodeAlias(Name)
   if node[Name] then return end -- Function exists
   local Func = string[Name]
   trace(Func)
   node[Name] = 
      function (self) 
         return Func(self:S())
      end
   local HelpData = help.get(Func)
   if HelpData then
      help.set{input_function=node[Name], help_data=help.get(Func)}
   end
end

local function MakeNodeAlias1(Name)
   if node[Name] then return end -- Function exists
   local Func = string[Name]
   trace(Func)
   node[Name] = 
      function (self,A) 
         return Func(self:S(),A)
      end
   local HelpData = help.get(Func)
   if HelpData then
      help.set{input_function=node[Name], help_data=help.get(Func)}
   end
end

local function MakeNodeAlias2(Name)
   if node[Name] then return end -- Function exists
   local Func = string[Name]
   trace(Func)
   node[Name] = 
      function (self,A,B) 
         if not B then
            return Func(self:S(),A)
         else
            return Func(self:S(),A,B)
         end
      end
   local HelpData = help.get(Func)
   if HelpData then
      help.set{input_function=node[Name], help_data=help.get(Func)}
   end
end

local function MakeNodeAlias3(Name)
   if node[Name] then return end -- Function exists
   local Func = string[Name]
   trace(Func)
   node[Name] = 
      function (self,A,B,C)
         return Func(self:S(),A,B,C)
      end
   local HelpData = help.get(Func)
   if HelpData then
      help.set{input_function=node[Name], help_data=help.get(Func)}
   end
end

local function MakeNodeAlias4(Name)
   if node[Name] then return end -- Function exists
   local Func = string[Name]
   trace(Func)
   node[Name] = 
      function (self,A,B,C,D) 
         if not D then
             if not C then
                return Func(self:S(), A, B)
             else
                return Func(self:S(), A, B, C)
             end
         end
         return Func(self:S(),A,B,C,D)
      end
   local HelpData = help.get(Func)
   if HelpData then
      help.set{input_function=node[Name], help_data=help.get(Func)}
   end
end

-- We make node tree aliases of some of the more useful string functions
-- This means we don't need to cast to a string using :S() or tostring() before we use the function.
local function Init()
   MakeNodeAlias('trimWS')
   MakeNodeAlias('trimRWS')
   MakeNodeAlias('trimLWS')
   MakeNodeAlias('compactWS')
   MakeNodeAlias('capitalize')
   MakeNodeAlias('lower')
   MakeNodeAlias('reverse')
   MakeNodeAlias('upper')
   MakeNodeAlias1('split')
   MakeNodeAlias1('gfind')

   MakeNodeAlias2('sub')
   MakeNodeAlias2('rxmatch')

   MakeNodeAlias3('gsub')
   MakeNodeAlias3('find')

   MakeNodeAlias4('rxsub')
end

-- rxmatch, find, 

Init()