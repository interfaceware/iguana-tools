
-- Mapping ADT message
function MapADT(Msg, X)
   -- Notice how the PID segment is in a different spot
   -- from the lab messsage - see MapLab
   MapPatient(Msg.PID, X.message.patient)   
end