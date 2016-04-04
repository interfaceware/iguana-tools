mime = require 'mime'
-- This channel shows an example of sending a richly formatted email from within Iguana.

-- Email clients are notorious for their inconsistent support for web standards so your end experience
-- may vary a lot depending on your email client.

-- http://help.interfaceware.com/code/details/mime-lua

-- TO MAKE THIS WORK!
-- 1) You will need to edit the parameters below for your own STMP email server.
-- 2) If you want to run this code live in the editor you will need to uncomment the live=true
--    line to run this code in the editor.  Alternatively you can run the channel and have it send
--    the example email that way.
local User = 'EDIT ME - valid email account user name' 
local Password = 'EDIT ME - password to smtp server' -- i.e. smtp.gmail.com if you use Google Email as your smtp server
local Server = 'EDIT ME - smtp server goes here'
local From = 'EDIT ME - Joe Bloggs <joe.bloggs@acme.com>'
local To = 'EDIT ME - email address here'

function main()   
   local ProjectPath = iguana.project.root()..'/'..iguana.project.guid()..'/'
   local Template = mime.readFile(ProjectPath..'template.html')
   local LogoPath = ProjectPath..'iguana-logo.png'
   local TextPath = ProjectPath..'text.txt'
   trace(LogoPath)
   mime.send{debug=true,
      header = {To = To; 
         From = From; 
         Subject = 'Email from Iguana';},
      username = User,
      password = Password,
      server = Server, 
      -- note that the "to" param is actually what is used to send the email, 
      -- the entries in header are only used for display. 
      -- For instance, to do Bcc, add the address in the  'to' parameter but 
      -- omit it from the header.
      to = {To},
      from = From,
      body = Template,
      entity_type='text/html',
      use_ssl = 'try',
      attachments = {LogoPath, TextPath},  -- Filenames to attach
      --live=true -- UNCOMMENT THIS LINE to make it run in the editor!
   }
end