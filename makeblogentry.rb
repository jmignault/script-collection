#!/usr/bin/ruby

# $Id: makeblogentry.rb 27 2009-06-16 13:28:59Z johnmignault $

# Possibilities: also export subject headings and use as keys to produce 
# subject feeds.

outf = File.new(File.basename(ARGV[0], ".csv") + ".html", "w")

# normalize record numbers
def make_record(str)
  str[1..-2]
end

# remove check digit from exported record number
def make_xrecord(str)
  str[0..-2]
end

File.open(ARGV[0]).readlines.each do |l|
  if l =~ /^"RECORD/
    next
  end
  
  l.chop!
  line = String('')
  
  elms = l.split('|').collect! {|f| f.gsub!('"', "")}  

  if(elms[1].length != 0) 
    line = line + "<a href=\"http://opac.nybg.org/record=" + make_record(elms[0]) + "\"><b>" + elms[1] + "</b></a><br />"
    line = line + "<a href=\"http://opac.nybg.org/xrecord=" + make_xrecord(elms[0]) + "\"><em>xrecord link</em></a><br />"
  end
  
  if(elms[2].length != 0) 
   line = line + elms[2] + "<br />"
  end
  
  if(elms[3].length != 0)
    line = line + elms[3] + " <br />"
  end

  if line.length > 0
    line = line + "<p />"
    outf.puts(line)
  end
  
end

outf.close

