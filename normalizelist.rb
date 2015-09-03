#!/usr/bin/ruby

pres = Array.new
regs = Array.new
outf = File.new(File.basename(ARGV[0], ".csv") + " norm.csv", "w")

File.open(ARGV[0]).readlines.each do |l|
  if l =~ /^"CALL/
    l.gsub!("245|a", "TITLE")
    l.gsub!("(BIBLIO)", "")
    l = l.chop + ',"VOLS","PULLED"'
    regs.insert(-1, l)
    next
  end
  if l !~ /^"[lL]*[fF]+ /
    if l =~ /^"[^"]*\+[^"]*"/
      l = l.chop + ',"",""'
      pres.insert(-1, l)
    else
      if l !~ /^"[MmPX"]/
        l = l.chop + ',"",""'
        regs.insert(-1, l)
      end
    end
  end
end

regs.each {| l | outf.puts l }
pres.each {| l | outf.puts l }

outf.close


