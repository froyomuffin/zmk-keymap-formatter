require 'rubygems'
require 'bundler/setup'
Dir["app/**/*.rb"].each { |file| require_relative file }

file_name = ARGV[0]

if file_name.nil? || file_name.empty?
  puts "Enter a file name"
else
  puts "Formatting file: #{file_name}"

  formatted = KeymapFormatter.new(keymap_file: file_name).format

  File.write(file_name, formatted.join)
  
  puts "Done"
end
