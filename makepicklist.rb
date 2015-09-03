#!/usr/bin/ruby

pres = Array.new
regs = Array.new

# make filename based on the input file given as argument
outf = File.new(File.basename(ARGV[0], ".csv") + "-norm.csv", "w")

# utility bit to append 2 additional fields for "VOLS" and "PULLED" at eol
def fill_line(str)
  str = str.chop + ',"",""'
end
  
# loop through the file
File.open(ARGV[0]).readlines.each do |l|
  if l =~ /^"CALL/  # fix the header
    l.gsub!("245|a", "TITLE")
    l.gsub!("(BIBLIO)", "")
    l = l.chop + ',"VOLS","PULLED"'
    regs.insert(-1, l)
    next
  end

  # lines to be skipped
  # folio or large folio
  if l =~ /^"[lL]*[fF]+ /
    next
  end

  # archives materials
  if l =~ /^"RG/
    next
  end

  # bound pamphlets
  if l =~ /^"QK2.5/
    next
  end

  # partials
  if l =~ /^"In /
    next
  end

  if l =~ /^"With /
    next
  end

  # Rest are things we keep
  # Call nos beginning with a plus sign are pre-1855s in a separate section
  # so should be grouped together
  if l =~ /^"[^"]*\+[^"]*"/
    pres.insert(-1, fill_line(l))
    next
  else
    # everything else is in the regular stacks
    if l !~ /^"[MmPX"]/
      regs.insert(-1, fill_line(l))
      next
    end
  end

end

# write the 2 sections to the output file
regs.each {| l | outf.puts l }
pres.each {| l | outf.puts l }

outf.close


