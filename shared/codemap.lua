-- This code map module has a number of useful helper 
-- routines for doing mapping and checking codes etc.

-- http://help.interfaceware.com/v6/codemap-example
 
local codemap = {}
 
-- Make a set
-- local MySet = codemap.set{"Fred", "Bruce", "Jim"}
-- if MySet[Msg.PID[3][1][1]] then print('One of our three amigos') end
function codemap.set(a)
   local m = {}
   for _,v in ipairs(a) do m[v] = true end
   return codemap.map(m, false)
end
 
-- Create a map the advantage of this function is that it will take a tree node without
-- needing to convert it to a string. 
-- Example of usage:
-- local SexMap = codemap.map({'M'='Male', 'm'='Male', 'F'='Female', 'f'='Female'},'default')
function codemap.map(m, default)
   return setmetatable(m, {
         __index = function(m,k)
            if type(k) ~= 'string' then
               local v = rawget(m, tostring(k))
               if v ~= nil then return v end
            end
            return default
         end})
end

-- help for functions

local HELP_DEF=[[{
"Desc": "Make a code set for membership checking, by supplying one or more key values <u>table</u>.
Membership is checked against the table keys.<br><br>
<b>Note</b>: The value (in each key/value pair) is set to a placeholder value of 'true'.",
"Returns": [
{
"Desc": "Code set used for membership checking <u>table</u>."
}
],
"SummaryLine": "Make a code set for membership checking.",
"SeeAlso": [
{
"Title": "Map data fields",
"Link": "http://help.interfaceware.com/v6/codemap-example"
},
{
"Title": "Module for mapping data fields",
"Link": "https://github.com/interfaceware/iguana-tools/blob/master/shared/codemap.lua"
}
],
"Title": "codemap.set",
"Usage": "codemap.set{&lt;key&gt; [, &lt;key&gt; ,...]}",
"Parameters": [
{
"Codeset": {
"Desc": "A table of key values <u>table</u>. "
}
}
],
"Examples": [
"<pre>local AmigoSet = codemap.set{'Fred', 'Jim', 'Harry'}
local isMember = AmigoSet['Harry']   -- true
local isMember = AmigoSet['William'] -- false</pre>"
],
"ParameterTable": true
}]]

help.set{input_function=codemap.set, help_data=json.parse{data=HELP_DEF}}

-- Create a map the advantage of this function is that it will take a tree node without
-- needing to convert it to a string.  Example of usage
-- SexMap = codemap.map({'M'='Male', 'm'='Male', 'F'='Female', 'f'='Female'},'default')
 local HELP_DEF=[[{
"Desc": "Make a codemap table, to use for mapping one codeset to another.",
"Returns": [
{
"Desc": "A codemap table for codeset mapping <u>table</u>."
}
],
"SummaryLine": "Make a codemap.",
"SeeAlso": [
{
"Title": "Map data fields",
"Link": "http://help.interfaceware.com/v6/codemap-example"
},
{
"Title": "Module for mapping data fields",
"Link": "https://github.com/interfaceware/iguana-tools/blob/master/shared/codemap.lua"
}
],
"Title": "codemap.map",
"Usage": "codemap.map({&lt;key&gt; = &lt;value&gt; [, &lt;key&gt; = &lt;value&gt; ,...]} [, &lt;default&gt])",
"Parameters": [
{
"Codemap": {
"Desc": "A table of key/value pairs to map from/to <u>table</u>."
}
},
{
"Default": {
"Desc": "Default value to use if there is no matching key <u>string</u>.","Opt":true
}
}
],
"Examples": [
"<pre>local SexMap = codemap.map({'M'='Male',  'F'='Female', 'W'='Female'},'other')
local Mapping = SexCodeMap['M'] -- maps to 'Male'
local Mapping = SexCodeMap['W'] -- maps to 'Female'
local Mapping = SexCodeMap['f'] -- maps to 'other'
</pre>"
],
"ParameterTable": false
}]]

help.set{input_function=codemap.map, help_data=json.parse{data=HELP_DEF}}

return codemap