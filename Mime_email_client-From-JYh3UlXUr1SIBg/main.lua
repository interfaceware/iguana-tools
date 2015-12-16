mime = require 'mime'
-- See http://help.interfaceware.com/code/details/mime-lua
-- This channel shows an example of sending a richly formatted email from within Iguana.

-- You will need to edit the parameters below for your own STMP email server to make this work

-- Email clients are notorious for their inconsistent support for web standards so your end experience
-- may vary a lot depending on your email client.

local User = '< valid email account user name >'
local Password = '< password to smtp server >'
local Server = '< smtp server goes here >'
local From = 'Joe Bloggs <joe.bloggs@acme.com>'
local To = '< email address here>'

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
      --live = true -- uncomment to run in the editor
   } 
end
