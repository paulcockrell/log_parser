$:.unshift("lib")
require "parser"

format = "%-10s %-50s %-20s" 
parser = Parser.new log_file: ARGV[0]
parser.parse

puts "Total line count: #{parser.line_count}, lines processed: #{parser.valid_lines.count}"

puts

puts "[URIs by visits]"
puts format % ["Index", "URI path", "Count"]
parser.order_uris_by_visits.each_with_index do |result, i|
  puts format % [ i+1, result.uri_path, result.count ]
end

puts

puts "[URIs by unique visits]"
puts format % ["Index", "URI path", "Count"]
parser.order_uris_by_unique_visits.each_with_index do |result, i|
  puts format % [ i+1, result.uri_path, result.count ]
end

  


