-- require imports a shared module into the project (See Project Manager on left)

require 'ran'

-- This is a very rough example showing how we can generate random HL7
-- data using the translator.  
      
function main()
   -- Push the ADT message through to destination
   -- Press 'RandomMessage' on right to navigate
   -- through code
   queue.push{data=ran.RandomMessage()}
end

