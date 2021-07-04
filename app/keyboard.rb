require 'rubygems'
require 'bundler/setup'

class Keyboard
  attr_reader :layout
  attr_reader :rows

  def initialize(layout:, raw_rows:)
    @layout = layout[:distribution]
    @rows = parse_rows(raw_rows).zip(@layout).map do |row, row_layout|
      Row.new(row: row, row_layout: row_layout)
    end
  end

  def render
    normalize_row_character_widths

    decorator_lines = DecoratorLines.for(@rows)
    command_lines = CommandLines.for(@rows)

    decorator_lines.zip(command_lines).flatten.compact
  end

  private

  def parse_rows(raw_rows)
    raw_rows
      .select { |row| row.include?('&') }
      .map do |row|
        row
          .split('&')
          .map(&:strip)
          .reject(&:empty?)
          .map do |key|
            key.gsub(/\s+/, " ")
          end.compact
      end
  end

  def normalize_row_character_widths
    densest_key = @rows.flat_map(&:keys).max { |key_a, key_b| key_a.density <=> key_b.density }
    target_characters_per_unit = densest_key.density
    @rows.each { |row| row.adjust_characters_per_unit_to(target_characters_per_unit) }

    target_row_character_width = @rows.map(&:character_width).max
    @rows.each { |row| row.adjust_character_width_to(target_row_character_width) }
  end
end
