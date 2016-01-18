dateparse = require 'dateparse'
-- dateparse automatically translates a wide variety of date/time formats
-- http://help.interfaceware.com/kb/298/6

function main(Data)
   local Msg = hl7.parse{data=Data, vmd='demo.vmd'}
   local T = db.tables{vmd='demo.vmd', name='ADT'}
   
   MapPatient(T.patient[1], Msg.PID)
end

function MapPatient(T, PID)
   T.Id = PID[3][1][1]
   T.LastName = PID[5][1][1][1]
   T.GivenName = PID[5][1][2]
   -- example of using the dateparse node :D()
   -- function to return a date without time
   T.Dob = PID[7][1]:D()
end