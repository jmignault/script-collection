#!/usr/bin/env ruby
require 'marc'

# reading records from a batch file
infile = ARGV.first
outfile = infile.split('.').first + '.xml'

reader = MARC::ForgivingReader.new(infile, :invalid => :replace)
writer = MARC::XMLWriter.new(outfile)

for record in reader
  writer.write(record)
end

writer.close()
