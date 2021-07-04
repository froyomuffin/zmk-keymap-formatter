require 'rubygems'
require 'bundler/setup'
Dir["app/**/*.rb"].each { |file| require_relative file }

FILE = "samples/nice60.keymap"

formatter = KeymapFormatter.new(keymap_file: FILE)

result = formatter.format

result.each { |e| puts e }

exit

SAMPLE_LAYER = "samples/layer.keymap"

key_lines = File.readlines(SAMPLE_LAYER)
kb = Keyboard.new(
  layout: Keyboard::Layouts::SIXTY_PERCENT_ANSI,
  raw_rows: key_lines,
)

kb.render.each { |e| puts e }
