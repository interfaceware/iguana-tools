local rtf={}
 
-- RTF module - used to convert RTF document into plain text.
-- See http://help.interfaceware.com/code/details/rtf-lua
 
-- A simple set implementation in Lua
local function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
 
-- Which control sequences to ignore
local IgnoreSet = Set { 'info', 'fonttbl', 'colortbl', 'stylesheet', '*' }
local Out = '';
local StateStack = {};
local State;
 
-- States of the state machine
local PLAINTEXT = 1
local CONTROL = 2
local ARGUMENT = 3
local BACKSLASH = 4
local ESCAPED_CHAR = 5
 
-- Character destinationions
local USE = 0
local IGNORE = 1
 
-- To print an exception only the first time
local UnexpectedCharFound = false;
 
-- Sets current character destination (IGNORE or USE)
local function setDest (D)
   Dest = D    
end
 
local function pushState ()
   table.insert (StateStack, { ['Dest'] = Dest } )
end
 
local function popState ()
   local EL = table.remove (StateStack)
   setDest  (EL['Dest'])
end
 
-- Collect or ignore the character based on the current destination
local function putChar (C, B)
   if C == '\r' then
      C = '\n'
   end
   if Dest ~= IGNORE then
      Out = Out..C
   end
end
 
local function isAlpha (C)
   return string.match (C, "%a") ~= nil
end
 
local function isDigit (C)
   return string.match (C, "%d") ~= nil
end
 
local function isSpace (C)
   return string.match (C, "%s") ~= nil
end
 
-- Process an RTF control word
-- T is token
-- A is argument
local function doControl (T, A)
   if T == 'par' then
      putChar ('\n')
   elseif IgnoreSet[T] then
      setDest (IGNORE)
   end
end
 
local function feedChar (C, B)
   local function nextState (C, B, CheckSpace)
      if C == '\\' then
         State = BACKSLASH
      elseif C == '{' then
         pushState ()
      elseif C == '}' then
         popState ()
      else
         if not CheckSpace or not isSpace (C) then
            putChar (C, B)
         end
      end       
   end
 
   if State == PLAINTEXT then
      nextState (C, B, false)
   elseif State == BACKSLASH then
      if C == '\\' or C == '{' or C == '}' then
         putChar (C)
         State = PLAINTEXT
      else
         if isAlpha (C) or C == '*' or C == '-' or C == '|' then
            State = CONTROL
            Token = C
         elseif C == "'" then
            State = ESCAPED_CHAR
            EscapedChar = ''
         elseif C == '\\' or C == '{' or C == '}' then
            putChar (C)
            State = PLAINTEXT
         elseif C == '~' then
            putChar (' ')
            state = PLAINTEXT
         else
            if (UnexpectedCharFound ~= true) then
               print ('Exception: unxepected '..C..' after \\')
               UnexpectedCharFound = true
            end
         end           
      end
   elseif State == ESCAPED_CHAR then
      EscapedChar = EscapedChar..C
      if #EscapedChar == 2 then
         C = string.char (tonumber (EscapedChar, 16))
         putChar (C)
         State = PLAINTEXT
      end
   elseif State == CONTROL then
      if isAlpha (C) then
         Token = Token..C
      elseif isDigit (C) or C == '-' then
         State = ARGUMENT
         Arg = C
      else
         doControl (Token, Arg)
         State = PLAINTEXT
         nextState (C, B, true)
      end
   elseif State == ARGUMENT then
      if isDigit (C) then
         Arg = Arg .. C
      else
         State = PLAINTEXT
         doControl (Token, Arg)
         nextState (C, B, true)
      end
   end
end
 
-- 
-- Public API
-- 
 
-- Given an RTF document as a Lua string (Data), return the text
-- portion of the document.
function rtf.toTxt(Data)
   Out = ''
   StateStack = { }
   State = PLAINTEXT
   setDest (USE)
 
   Data = string.gsub (Data, '\r', '')
   Data = string.gsub (Data, '\n', '')
 
   local i = 1
   for i = 1, #Data do
      local B = string.byte (Data, i)
      feedChar (string.char (B), B)
   end
   return Out
end
 
return rtf