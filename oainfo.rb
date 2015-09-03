#!/usr/local/bin/ruby
# $Id
require 'oai'

client = OAI::Client.new ARGV[0]

id = client.identify
puts "Basic info:"
puts "name: " + id.repository_name.to_s
puts "protocol: " + id.protocol.to_s
puts "granularity: " + id.granularity.to_s

formats = client.list_metadata_formats
puts "Formats:"
for format in formats
  puts format.prefix.to_s + " => " + format.namespace.to_s
end

sets = client.list_sets
puts "Sets:"
for set in sets
  puts set.spec + " => " + set.name + ": " + set.description.get_elements('.//dc:description').first.get_text.to_s
end


