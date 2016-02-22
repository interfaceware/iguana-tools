-- The stringutil module
-- Copyright (c) 2011-2012 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in accordance
-- with the terms of the iNTERFACEWARE license agreement accompanying the software
-- in which it is used.
-- http://help.interfaceware.com/code/details/stringutil-lua

-- stringutil contains a number of extensions to the standard Lua String library. 
-- As you can see writing extra methods that will work on strings is very easy. 
-- http://www.lua.org/manual/5.1/manual.html#5.4 for documentation on the Lua String library

-- This version of stringutil goes a little further in that it defines these operations
-- directly on node tree objects.

-- Trims white space on both sides.
function string.trimWS(self)
   return self:match('^%s*(.-)%s*$')
end

-- Trims white space on right side.
function string.trimRWS(self)
   return self:match('^(.-)%s*$')
end

-- Trims white space on left side.
function string.trimLWS(self)
   return self:match('^%s*(.-)$')
end

-- This routine will replace multiple spaces with single spaces 
function string.compactWS(self) 
   return self:gsub("%s+", " ") 
end

-- This routine capitalizes the first letter of the string
-- and returns the rest in lower characters
function string.capitalize(self)
   local R = self:sub(1,1):upper()..self:sub(2):lower()
   return R
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
         Title="stringutil.lua - in our code repository.",
         Link="http://help.interfaceware.com/code/details/stringutil-lua"
      },
      {
         Title="Stringutil – string functions ",
         Link="http://help.interfaceware.com/v6/stringutil-string-functions"
      }
   }
}

help.set{input_function=string.trimWS, help_data=trimWS_help}

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
         Title="stringutil.lua - in our code repository.",
         Link="http://help.interfaceware.com/code/details/stringutil-lua"
      },
      {
         Title="Stringutil – string functions ",
         Link="http://help.interfaceware.com/v6/stringutil-string-functions"
      }
   }
}

help.set{input_function=string.trimRWS, help_data=trimRWS_help}

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
         Title="stringutil.lua - in our code repository.",
         Link="http://help.interfaceware.com/code/details/stringutil-lua"
      },
      {
         Title="Stringutil – string functions ",
         Link="http://help.interfaceware.com/v6/stringutil-string-functions"
      }
   }
}

help.set{input_function=string.trimLWS, help_data=trimLWS_help}

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
         Title="stringutil.lua - in our code repository.",
         Link="http://help.interfaceware.com/code/details/stringutil-lua"
      },
      {
         Title="Stringutil – string functions ",
         Link="http://help.interfaceware.com/v6/stringutil-string-functions"
      }
   }
}

help.set{input_function=string.compactWS, help_data=compactWS_help}

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
         Title="stringutil.lua - in our code repository.",
         Link="http://help.interfaceware.com/code/details/stringutil-lua"
      },
      {
         Title="Stringutil – string functions ",
         Link="http://help.interfaceware.com/v6/stringutil-string-functions"
      }
   }
}
help.set{input_function=string.capitalize, help_data=capitalize_help}

-- This helper function takes the name of a string function and makes an equivalent node function
-- If it can get the help then it gets that too.
function MakeNodeAlias(Name)
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

-- We make node tree aliases of some of the more useful string functions
-- This means we don't need to cast to a string using :S() or tostring() before we use the function.

MakeNodeAlias('trimWS')
MakeNodeAlias('trimRWS')
MakeNodeAlias('trimLWS')
MakeNodeAlias('compactWS')
MakeNodeAlias('capitalize')
MakeNodeAlias('split')
MakeNodeAlias('rxsub')
MakeNodeAlias('upper')
MakeNodeAlias('gsub')
MakeNodeAlias('lower')
MakeNodeAlias('sub')
MakeNodeAlias('reverse')
MakeNodeAlias('rxmatch')
