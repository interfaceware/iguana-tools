-- See http://help.interfaceware.com/v6/log_annotate 
-- Have a look at the main HTTP translator instance to see how
-- to run this example

require 'log.annotate'

function main(Data)
   iguana.logInfo("Applying transformation to "..Data)
   queue.push{data=Data}
end