-- The mime module
-- Copyright (c) 2011-2015 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in
-- accordance with the terms of the iNTERFACEWARE license agreement
-- accompanying the software in which it is used.
 
-- Basic SMTP/MIME module for sending MIME formatted attachments via
-- SMTP.
--
-- An attempt is made to format the MIME parts with the correct headers,
-- and pathnames that represent non-plain-text data are Base64 encoded
-- when constructing the part for that attachment.
--
-- SMTP/MIME is a large and complicated standard; only part of those
-- standards are supported here. The assumption is that most mailers
-- and mail transfer agents will do their best to handle inconsistencies.
--
-- Example usage:
--
-- local Results = mime.send{
--    server='smtp://mysmtp.com:25', username='john', password='password',
--    from='john@smith.com', to={'john@smith.com', 'jane@smith.com'},
--    header={['Subject']='Test Subject'}, body='Test Email Body', use_ssl='try',
--    attachments={'/home/jsmith/pictures/test.jpeg'},
-- }
 
local mime = {}
 

-- Common file extensions and the corresponding MIME sub-type we will probably encounter. Add more as necessary.
local MIMEtypes = {
  ['pdf']  = 'application/pdf',
  ['jpeg'] = 'image/jpeg',
  ['jpg']  = 'image/jpeg',
  ['gif']  = 'image/gif',
  ['png']  = 'image/png',
  ['zip']  = 'application/zip',
  ['gzip'] = 'application/gzip',
  ['tiff'] = 'image/tiff',
  ['html'] = 'text/html',
  ['htm']  = 'text/html',
  ['mpeg'] = 'video/mpeg',
  ['mp4']  = 'video/mp4',
  ['txt']  = 'text/plain',
  ['exe']  = 'application/plain',
  ['js']   = 'application/javascript',
}

local function getContentType(FileExtension)  
   return MIMEtypes[FileExtension] or 'application/unknown'
end

-- Most mailers support UTF-8
local defaultCharset = 'utf8'
 
-- Read the passed in filespec into a local variable.
function mime.readFile(Filename)
   local F = assert(io.open(Filename, "rb"))
   local Data = F:read("*a")
   F:close()
   return Data
end
    
-- Base64 encode the content passed in. Break the encoded data into reasonable lengths per RFC2821 and friends.
-- Most mail clients can handle about 990-1000 - Maxline can be reduced down to 72 for debugging.
local function Base64Encode(Content)
   local Lines = {''}
   local Encoded = filter.base64.enc(Content)
   local Maxl = 990 - 2  -- Less 2 for the trailing CRLF pair
   local Len = #Encoded
   local Start = 1
   local Lineend = Start + Maxl
   while Start < Len do
      Lines[#Lines+1] = Encoded:sub(Start,Start+Maxl)
      Start = Start + Maxl + 1
   end
   trace(Lines)

   return table.concat(Lines, '\r\n')
end


local function AddAttachments(FileList, partBoundary)
   local Body = ''
   for _, FilePath in ipairs(FileList) do
      local path, Filename, Extension = FilePath:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
      -- Get the (best guess) content-type and file contents.
      -- Cook the contents into Base64 if necessary.
      local contentType = getContentType(Extension)
      local Content = mime.readFile(FilePath)
      local isBinary = Content:find("[^\f\n\r\t\032-\128]");
      if isBinary then
         Content = Base64Encode(Content)
      end
      local Charset = isBinary and 'B' or defaultCharset
      -- We could use "quoted-printable" to make sure we handle
      -- occasional non-7-bit text data, but then we'd have to break
      -- the passed-in data into max 76 char lines. We don't really
      -- want to munge the original data that much. Defaulting to 
      -- 7bit should work in most cases, and supporting quoted-printable
      -- makes things pretty complicated (and increases the message
      -- size even more.)
      local ContentTransferEncoding = isBinary and 'Content-Transfer-Encoding: base64' or ''

      -- Concatenate the current chunk onto the entire body.
      Body = Body..'\r\n\r\n'
         ..partBoundary..'\r\n'
         ..'Content-Type: '..contentType..'; charset="'..Charset..'"; name="'..Filename..'"\r\n'
         ..'Content-ID: <'..Filename..'>\r\n'
         ..'Content-Disposition: attachment; filename="'..Filename..'"\r\n'
         ..ContentTransferEncoding..'\r\n'
         ..Content..'\r\n'
   end
   return Body
end
 
-- Similar to net.smtp.send with a single additional required parameter
-- of an array of local absolute filenames to add to the message
-- body as attachments.
--
-- An attempt is made to add the attachment parts with the right
-- MIME-related headers.
function mime.send(args)
   local server = args.server
   local to = args.to
   local from = args.from
   local header = args.header
   local body = args.body
   local attachments = args.attachments
   local username = args.username
   local password = args.password
   local timeout = args.timeout
   local use_ssl = args.use_ssl
   local live = args.live
   local debug = args.debug
   local entity_type = args.entity_type or 'text/plain'

   -- Blanket non-optional parameter enforcement.
   if server == nil or to == nil or from == nil
      or header == nil or body == nil
      or attachments == nil then
      error("Missing required parameter.", 2)
   end
   header['Date'] = os.ts.date("!%a, %d %b %Y %H:%M:%S GMT");

   -- Create a unique ID to use for multi-part boundaries.
   local boundaryID = util.guid(128)
   if debug then  -- debug hook
      boundaryID = 'xyzzy_0123456789_xyzzy'
   end
   local partBoundary = '--' .. boundaryID
   local endBoundary = '--' .. boundaryID .. '--'

   -- Append our headers, set up the multi-part message.
   header['MIME-Version'] = '1.0'
   header['Content-Type'] = 'multipart/mixed; boundary=' .. boundaryID

   -- Preload the body part.
   local msgBody = partBoundary..'\r\n'
      ..'Content-Type: '..entity_type..'; charset="'..defaultCharset..'"\r\n'
      ..'\r\n'..body
   msgBody = msgBody..AddAttachments(attachments, partBoundary) 
   msgBody = msgBody..'\r\n'..endBoundary
   trace(msgBody)

   -- Send the message via net.smtp.send()
   net.smtp.send{
      server = server,
      to = to,
      from = from,
      header = header,
      body = msgBody,
      username = username,
      password = password,
      timeout = timeout,
      use_ssl = use_ssl,
      live = live,
      debug = debug
   }
   -- Debug hook
   if debug then
      return msgBody, header
   end
end
 
local mimehelp = {
   Title="mime.send";
   Usage="mime.send{server=<value> [, username=<value>] [, ...]}",
   Desc=[[Sends an email using the SMTP protocol. A wrapper around net.smtp.send.
   Accepts the same parameters as net.smtp.send, with an additional "attachments"
   parameter:
   ]];
   ["Returns"] = {
      {Desc="Normally nothing.  If the debug flag is set to true then the email body and email header is returned."},
   };
   ParameterTable= true,
   Parameters= {
      {attachments= {Desc='A table of absolute filenames to be attached to the email.'}},
   };
   Examples={
      [[local Results = mime.send{
      server='smtp://mysmtp.com:25', username='john', password='password',
      from='john@smith.com', to={'john@smith.com', 'jane@smith.com'},
      header={['Subject']='Test Subject'}, body='Test Email Body', use_ssl='try',
      attachments={'/home/jsmith/pictures/test.jpeg'},
   }]],
   };
   SeeAlso={
      {
         Title="net.smtp - sending mail",
         Link="http://wiki.interfaceware.com/1039.html#send"
      },
      {
         Title="Tips and tricks from John Verne",
         Link="http://wiki.interfaceware.com/1342.html"
      }
   }
}

help.set{input_function=mime.send, help_data=mimehelp}
 
return mime