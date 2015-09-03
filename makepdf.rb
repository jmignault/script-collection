#!/usr/local/bin/ruby
# $Id
require "pdf/writer"
require 'getoptlong'

indir = ''
outfile = ''

opts = GetoptLong.new(
[ "--directory", "-d", GetoptLong::REQUIRED_ARGUMENT ],
[ "--output", "-f", GetoptLong::REQUIRED_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
  when '--output'
    outfile = arg.to_s
  when '--directory'
    indir = arg.to_s
  end
end

pdf = PDF::Writer.new
pdf.compressed = true

dir = Dir.entries(indir).delete_if {|x| x =~ /^\./}

dir.each do |f|
  pdf.image f, :justification => :center
end

File.open(outfile, "wb") { |fn| fn.write pdf.render }
