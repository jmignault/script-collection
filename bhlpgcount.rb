#!/usr/bin/env ruby
require 'rexml/document'
require 'open-uri'

sciname = ARGV.first

xmlstr = open('http://www.biodiversitylibrary.org/api2/httpquery.ashx?op=NameGetDetail&name=' + sciname + '&apikey=deabdd14-65fb-4cde-8c36-93dc2a5de1d8') {|f| 
       str = f.read()
}

xdoc = REXML::Document.new(xmlstr)
pgs = xdoc.root.get_elements("//Page")
pgids = xdoc.root.get_elements("//PageID")

puts pgs.count
puts pgids.count


