#!/usr/local/bin/ruby 
# $Id
require 'marc'
reader = MARC::Reader.new('/Users/johnmignault/downloads/gift test 04_06.exp')
reader.each {|r| puts r['245']}