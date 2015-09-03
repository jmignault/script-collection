#!/usr/local/bin/ruby
# $Id: wonderfetch.rb 30 2012-01-05 17:20:54Z  $
# wonderfetch.rb: a first stab at making a fairly extensible, easily
# configured wonderfetch generator. Basically a configuration file is
# used to set up 2 types of variables: string constants and array indices.
# Ideally we should probably do this with dictionaries, but that might make
# the rcfile more difficult to maintain. Also script is dependent on csv
# exports of data.
# This script outputs fully conformant XHTML 1.1.

require 'uri' # for escape func
require 'rexml/document'
include REXML

# constants, filenames, options
rc_name = ENV['HOME'] + '/.wfrc'
in_name = ARGV[0]
pg_name = File.basename(in_name, '.csv')
out_name = pg_name + '_wf.html'
biblio_urls =   {'pre' => 'http://www.us.archive.org/biblio.php?f=c',
                'scan' => 'http://localhost.archive.org/biblio.php?f=c'}

# i/o festival
rcfile = File.open(rc_name)
inf = File.open(in_name)

# read in each line of the file and eval it as a global variable
# TODO: assign indices based on heading list at start of file rather than hardcoding in .rc
rcfile.readlines.each do |line|
  next if (line =~ /^#/ or line =~ /^$/) # allow for comments or blank lines in rcfile
    eval('$' + line)
end

doc = Document.new
xmldec = XMLDecl.new()
xmldec.encoding=('UTF-8')
doc.add(xmldec)
doc.add(REXML::DocType.new('html',
    'PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"'))
index_html = Element.new("html")
index_html.attributes['xmlns'] = 'http://www.w3.org/1999/xhtml'
head = Element.new("head")

pgtitle = Element.new("title")
text = Text.new(pg_name)
pgtitle.add(text)

head.add(pgtitle)
index_html.add(head)

body = Element.new("body")

div = Element.new("div")

heading = Element.new("h1")
heading.text = pg_name + ' - wonderfetch URLS'
div.add(heading)

link_num = 1
# loop through the import and make a whole bunch of ugly URLs
inf.readlines.each do | line |
  if line =~ /^"RECORD/
    next
  end
  wf_url = biblio_urls[$loader]
  fields = line.encode('UTF-8', :invalid => :replace).split(/,/)
  fields.map! { |f| f.gsub(/"/, '') }
  wf_url += '&z_c=' + URI.escape($zterm)
  wf_url += '&z_d=' + URI.escape(fields[$localno])
  wf_url += '&z_e=' + URI.escape($zcatalog)
  wf_url += '&b_v=' + URI.escape(fields[$volume])
  wf_url += '&year=' + URI.escape(fields[$year])
  wf_url += '&b_l=' + URI.escape($contributor)
  # wf_url += '&b_p=' + URI.escape($sponsor)
  wf_url += '&b_n=' + URI.escape($center)
  wf_url += '&b_c2=' +  URI.escape($collection.join(';'))
  wf_url += '&b_ib=' + fields[$localno]
  wf_url += '&pcs=' + URI.escape($copyright)
  wf_url += '&rights=' + URI.escape($rights)
  wf_url += '&dd=' + URI.escape($permissions)
  link = Element.new("a")
  link.attributes['href'] = wf_url
  link.text = link_num.to_s + '. ' + fields[$title] + ' - ' + fields[$oclc]
  link_num += 1
  div.add(link)
  div.add(Element.new("br"))
end

body.add(div)
index_html.add(body)
doc.add(index_html)
doc.write(File.new(out_name, 'w'))


