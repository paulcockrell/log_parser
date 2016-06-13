$:.unshift("lib")
require "log_parser/log_file_reader"
require "log_parser/uri_visit_counter"

LINE_REGEX = /^(\/[a-z0-9\-_\/]*)\s((?:\d{1,3}\.){3}\d{1,3})/
FORMAT = "%-10s %-50s %-20s"

if ARGV.empty?
  puts "Please supply a paths to web log files to process, e.g: ruby parser.rb ./weblog.log ./weblog.log.1"
  exit
end

log_file_reader = LogParser::LogFileReader.new log_files: ARGV, line_regex: LINE_REGEX
uri_visit_counter = LogParser::UriVisitCounter.new log_file_reader.readings

if invalid_log_files = log_file_reader.invalid_log_files 
  puts "Rejected files: #{invalid_log_files.join(", ")}" unless invalid_log_files.empty?
end

puts "Total line count: #{log_file_reader.line_count}, valid lines: #{log_file_reader.readings.count}"

if log_file_reader.readings.count < 1
  puts "No data to display"
  exit
end

puts

puts "[URIs by visits]"
puts FORMAT % ["Index", "URI path", "Count"]
uri_visit_counter.uris_by_visits.each_with_index do |uri, i|
  puts FORMAT % [ i+1, uri.uri_path, uri.visit_count ]
end

puts

puts "[URIs by unique visits]"
puts FORMAT % ["Index", "URI path", "Count"]
uri_visit_counter.uris_by_unique_visits.each_with_index do |result, i|
  puts FORMAT % [ i+1, result.uri_path, result.unique_visit_count ]
end

  


