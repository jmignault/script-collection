#!/usr/bin/env ruby
# $Id
require 'zoom'
require 'marc'
require 'getoptlong'

# defaults
host = 'opac.nybg.org'
port = 210
db = 'INNOPAC'
syntax = 'USMARC'
query = ''

opts = GetoptLong.new( 
                      [ "--host", "-h", GetoptLong::OPTIONAL_ARGUMENT ], 
                      [ "--syntax", "-s", GetoptLong::OPTIONAL_ARGUMENT ], 
                      [ "--query", "-q", GetoptLong::REQUIRED_ARGUMENT ], 
                      [ "--db", "-d",  GetoptLong::OPTIONAL_ARGUMENT ], 
                      [ "--port", "-p",  GetoptLong::OPTIONAL_ARGUMENT ] 
                      ) 

opts.each do |opt, arg| 
  case opt
  when '--host'
    host = arg.to_s
  when '--syntax'
    syntax = arg.to_s
  when '--query'
    query = arg.to_s
  when '--db'
    db = arg.to_s
  when '--port'
    port = arg.to_i
  end
end

ZOOM::Connection.open(host, port) do |conn|
  conn.database_name = db
  conn.preferred_record_syntax = syntax
  rset = conn.search(query)
  rset.each_record do |r|
    puts r.render
    # record = MARC::Record.new_from_marc(r.to_s)
  end
end
