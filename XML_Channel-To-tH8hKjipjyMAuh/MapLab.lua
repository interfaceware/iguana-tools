
-- Function mapping lab data with a non trivial
-- manipulation of text formatted into NTE segments.  

function MapLab(Msg, X)
   MapPatient(Msg.PATIENT.PID, X.message.patient)
   local Result = X.message.lab_info:text()
   
   -- Let's convert to text
   Result= Result:S()
   
   -- Split the lines
   local Lines = Result:split('\n')
   -- Then get rid of white space
   for i=#Lines, 1, -1 do
      Lines[i] = Lines[i]:trimWS()
      -- Then remove blank lines
      if #Lines[i] == 0 then
          table.remove(Lines, i)
      end
   end
   trace(Lines)
 
   -- Create NTE segments for each line
   for i=1, #Lines do
      Msg.ORDER[1].ORDER_DETAIL.NTE[i][3][1] = Lines[i]
   end
   trace(Msg)
end