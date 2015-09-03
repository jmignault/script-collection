#!/usr/local/bin/ruby
require 'zoom'
require 'getoptlong'

opts = GetoptLong.new( 
                      [ "--attr", "-a", GetoptLong::OPTIONAL_ARGUMENT ], 
                      [ "--val", "-v", GetoptLong::OPTIONAL_ARGUMENT ] 
                      ) 

attrs = { 'oclc' => '1211', 'local' => '12', 'author' => '1', 'title' => '4', 'isbn' => '7', 'call' => '16'}

opts.each do |opt, arg| 
  case opt
  when '--attr'
    $attr = attrs[arg.to_s]
  when '--val'
    $val = arg.to_s
  end
end


ZOOM::Connection.open('opac.nybg.org', 210) do |conn|
    conn.database_name = 'INNOPAC'
    conn.preferred_record_syntax = 'MARC21'
    rset = conn.search('@attr 1=' + $attr + ' "' + $val + '"')
    rset.each_record {|rec| puts rec.to_s + "\n" }
end
