require 'example.duplicate_filter'
require 'example.zsegment'

-- This channel shows the usage of a number of useful 'power' user modules for Iguana.
-- We make it easy to get all of these in one channel and see an example of using each module.

function main(Data)
   ParseZSegments(Data)
   FilterDuplicates(Data)
end

