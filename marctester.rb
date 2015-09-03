#!/usr/bin/env ruby
# $Id
require 'marc'

reader = MARC::Reader.new(ARGV[0])
for record in reader
  puts record['245']
end
