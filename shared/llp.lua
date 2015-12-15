-- llp module - allows Lua to act as a LLP client
-- See http://help.interfaceware.com/code/details/llp-lua

-- Here we expose a single function, connect(), that opens
-- an LLP connection to a remote host, and returns a table
-- to interact with.  When debugging, it actually returns
-- a fake connection, which can be sent HL7 messages, and
-- replies with ACKs (one ACK per message sent).
--
-- If you want to test a real LLP connection in the editor,
-- pass live=true along with your connection settings.
--
-- local llp = require 'llp'
--
-- local s = llp.connect{host='frink',port=8086}
-- s:send(Data)
-- local Ack = s:recv()
-- s:close()
 
__llp = {
   send_llp = function(s, msg)
      local sent, text = 0, '\v'..msg..'\28\r'
      repeat
         sent = sent + s:send(text, sent+1)
      until sent >= text:len()
      return sent
   end;
   recv_llp = function(s, buf)
      local head = buf:find('\v', 1, true)
      local tail = head and buf:find('\28\r', head, true)
      while not tail do
         local part = s:recv()
         if not part then
            return nil, buf, ''
         end
         local old_end = buf:len()
         buf = buf..part
         head = head or buf:find('\v', old_end, true)
         if head then
            local i = math.max(old_end, head)
            tail = buf:find('\28\r', i, true)
         end
      end
      local msg = buf:sub(head + 1, tail - 1)
      local remainder = buf:sub(tail + 2)
      local skipped = buf:sub(1, head - 1)
      return msg, remainder, skipped
   end;
   real_meta = {
      __index = {
         send = function(self, msg)
            return __llp.send_llp(self.s, msg)
         end;
         recv = function(self)
            local msg, skipped
            msg, self.buf, skipped = __llp.recv_llp(self.s, self.buf)
            return msg, skipped
         end;
         close = function(self)
            self.s:close()
         end
      }
   };
   
   --
   -- Metatable for Simulation
   --
   
   simulation_meta = {
      __index = {
         send = function(self, msg)
            if not self.connected then
               error('not connected', 2)
            end
            self.sent = msg
            return msg:len()
         end;
         recv = function(self)
            if not self.connected then
               error('not connected', 2)
            elseif not self.sent then
               error('timeout', 2)
            else
               --local got = ack.generate(self.sent) -- OLD VERSION
               --ack.generate() only works in a From LLP script
               --replaced it with inline function "ackGenerate"
               --so module works in any component
               local ackGenerate = function(self)
                  local Msg = hl7.parse{vmd='ack.vmd', data=self.sent}
                  local Ack = hl7.message{vmd='ack.vmd', name='Ack'}
                  Ack.MSH[3][1]  = Msg.MSH[5][1]
                  Ack.MSH[4][1]  = Msg.MSH[6][1]
                  Ack.MSH[5][1]  = Msg.MSH[3][1]
                  Ack.MSH[6][1]  = Msg.MSH[4][1]
                  Ack.MSH[10]    = Msg.MSH[10]
                  Ack.MSH[9][1]  = 'ACK'
                  Ack.MSH[11][1] = 'P'
                  Ack.MSH[12][1] = Msg.MSH[12][1]
                  
                  Ack.MSA[1] = 'AA'
                  Ack.MSA[2] = Msg.MSH[10]
                  
                  return Ack:S()
               end;
               local got = ackGenerate(self)
               self.sent = nil
               return got
            end
         end;
         close = function(self)
            self.connected = false
         end
      }
   };
   
   --
   -- Error Checking
   --
   
   check_arg = function(args, k, t, optional)
      local help = [[Connect to a remote LLP host.
      Takes a table with the following required entries:
      'host' - the hostname of the remote site
      'port' - the port on the remote site
      and optionally these entries:
      'timeout' - maximum wait time, in seconds (default 5s)
      'live'    - create live LLP connections in the editor
      e.g. local s = llp.connect{host='hostname',port=8086}
      s:send(Data)
      local Ack = s:recv()
      s:close()
      ]]
      if not args then
         error(help, 3)
      elseif type(args) ~= 'table' then
         error('Parameter 1 is not a table.\n'..help, 3)
      elseif not optional and not args[k] then
         error("Parameter '"..k.."' is required.\n"..help, 3)
      elseif args[k] and type(args[k]) ~= t then
         error("Parameter '"..k.."' should be a "..t..'.\n'..help, 3)
      end
   end;
}
 
-- generate a 
function ackGenerate(Data)
   local Msg = hl7.parse{vmd='ack.vmd', data=Data}
   local Ack = hl7.message{vmd='ack.vmd', name='Ack'}
   Ack.MSH[3][1]  = Msg.MSH[5][1]
   Ack.MSH[4][1]  = Msg.MSH[6][1]
   Ack.MSH[5][1]  = Msg.MSH[3][1]
   Ack.MSH[6][1]  = Msg.MSH[4][1]
   Ack.MSH[10]    = Msg.MSH[10]
   Ack.MSH[9][1]  = 'ACK'
   Ack.MSH[11][1] = 'P'
   Ack.MSH[12][1] = Msg.MSH[12][1]
 
   Ack.MSA[1] = 'AA'
   Ack.MSA[2] = Msg.MSH[10]
 
   return Ack:S()
end
 
--
-- Public Interface
--
 
local llp = {}
function llp.connect(args)
   local required, optional = false, true
   __llp.check_arg(args, 'host',    'string',  required)
   __llp.check_arg(args, 'port',    'number',  required)
   __llp.check_arg(args, 'timeout', 'number',  optional)
   __llp.check_arg(args, 'live',    'boolean', optional)
   
   if args.live or not iguana.isTest() then
      -- Normal behaviour (in running channel).
      args.live = nil
      local Success, Socket = pcall(net.tcp.connect, args)
      if not Success then
         -- raise error to caller level
         error(Socket, 2)
      end
      return setmetatable({
            s   = Socket,
            buf = '',  -- input buffer.
         }, __llp.real_meta)
   else
      -- Simulate behaviour while editing.
      return setmetatable({
            connected = true,
         }, __llp.simulation_meta)
   end
end
 
return llp