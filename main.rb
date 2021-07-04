require 'rubygems'
require 'bundler/setup'
Dir["app/**/*.rb"].each { |file| require_relative file }

SAMPLE_LAYER = "samples/layer.keymap"

puts "Starting"

key_lines = File.readlines(SAMPLE_LAYER)
kb = Keyboard.new(
  layout: Keyboard::Layouts::SIXTY_PERCENT_ANSI,
  raw_rows: key_lines,
)

kb.render.each { |e| puts e }
