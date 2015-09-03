#!/usr/local/bin/ruby
#$Id: iablsplit.rb 27 2009-06-16 13:28:59Z johnmignault $
require 'csv'

in_name = ARGV[0]
pg_name = File.basename(in_name, '.csv')
out_name = pg_name + '_split.csv'
writer = CSV.open(out_name, 'w')

CSV.open(in_name, "r").each do |line|
  elms = line[2].split(/:/)
  if elms.length > 1
    bits = /([^0-9]+?) ([0-9\?]+)/.match(elms[0])
    if bits
      writer << [ line[0], line[1], bits[1], bits[2], elms[1], line[3], nil ]
    else
      writer << line
    end
  else
    writer << line
  end
end

writer.close
