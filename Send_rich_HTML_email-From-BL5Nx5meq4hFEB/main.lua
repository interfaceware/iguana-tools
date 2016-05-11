-- This channel shows an example of sending a richly formatted email from within Iguana.

-- Email clients are notorious for their inconsistent support for web standards so your end experience
-- may vary a lot depending on your email client.

-- See http://help.interfaceware.com/v6/mime-email-client

local mime = require 'mime'
local config = require 'encrypt.password'

local Key='sdfasdfakdsakjfweiuhwieuhwiuhc'

-- We make use of the encrypt.password module.
-- http://help.interfaceware.com/v6/encrypt-password-in-file


-- Follow these steps to store SMTP mail server credentials securely in 5 configuration files
-- This method is much more secure than saving database credentials in the Lua script
-- NOTE: (step 4) Be careful not to save a milestone containing password information
-- See http://help.interfaceware.com/v6/encrypt-password-in-file
-- To change the SMTP mail user, password, server, from email and to email addresses you'll need to 
--  1) Enter them into these lines
--  2) Uncomment the lines.
--  3) Recomment the lines
--  4) Remove the password and STMP servername from the file *BEFORE* you same a milestone

--config.save{key=Key,config="mail_user",    password="EDIT ME - username to smtp server"}
--config.save{key=Key,config="mail_password",password="EDIT ME - password to smtp server"}
--config.save{key=Key,config="mail_server",  password="EDIT ME - smtp server goes here"}
--config.save{key=Key,config="mail_from",    password="EDIT ME - Joe Bloggs <joe.bloggs@acme.com>"}
--config.save{key=Key,config="mail_to",      password="EDIT ME - email address here"}

-- If you want to run this code live in the editor you will need to uncomment the live=true
-- line to run this code in the editor. Alternatively you can run the channel and have it send
-- the example email that way.

function main()
   local User     = config.load{config="mail_user",     key=Key}
   local Password = config.load{config="mail_password", key=Key}
   local Server   = config.load{config="mail_server",   key=Key}
   local From     = config.load{config="mail_from",     key=Key}
   local To       = config.load{config="mail_to",       key=Key}
   
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