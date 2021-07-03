require 'rubygems'
require 'bundler/setup'

class Main
  SAMPLE_LAYER = "samples/layer.keymap"

  def self.run
    puts "Starting"

    key_lines = File.readlines(SAMPLE_LAYER)
    kb = Keyboard.new(key_lines, Layouts::SIXTY_PERCENT_ANSI)

    config_builder = LayoutBuilder.new(kb)

    puts config_builder.build
  end
end

class Keyboard
  attr_reader :unit_size
  attr_reader :key_lines
  attr_reader :keys

  def initialize(key_lines, layout)
    @unit_size = layout[:unit_size]

    raw_key_lines = key_lines.map do |line|
      line
        .split('&')
        .map(&:strip)
        .reject(&:empty?)
        .map do |key|
          key.gsub(/\s+/, " ")
        end
    end
    @key_lines = apply_layout_distribution(raw_key_lines, layout[:distribution])

    @keys = @key_lines.reduce([], :+)
  end

  private

  def apply_layout_distribution(key_lines, layout_distribution)
    key_lines.each_with_index.map do |key_line, index|
      layout_distribution_line = layout_distribution[index]

      key_line.each_with_index.map do |key_data, index|
        unit_size = layout_distribution_line[index]
        Key.new(key_data, unit_size)
      end
    end
  end
end

class Layouts
  SIXTY_PERCENT_ANSI = {
    unit_size: 15,
    distribution: [
      [1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.00], 
      [1.50, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.50], 
      [1.75, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.25], 
      [2.25, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.75], 
      [1.25, 1.25, 1.25, 6.25, 1.25, 1.25, 1.25, 1.25], 
    ],
  }
end

class Key
  attr_reader :kind
  attr_reader :value
  attr_reader :unit_size
  attr_reader :density
  attr_reader :command

  attr_accessor :size_adjustment

  def initialize(key_data, unit_size)
    @kind, @value = key_data.split(' ')
    @kind = @kind.prepend('&')
    @command = [@kind, @value].join(' ')
    @unit_size = unit_size
    @density = @command.length / @unit_size
    
    @size_adjustment = 0
  end

  def adjusted_size(unit_length)
    (@unit_size * unit_length).ceil + @size_adjustment
  end
end

class LayoutBuilder
  def initialize(keyboard)
    @keyboard = keyboard

    @densest_key = @keyboard.keys.max { |key_a, key_b| key_a.density <=> key_b.density }
    @unit_length = @densest_key.density
  end

  def build
    target_line_size = @keyboard.key_lines.map { |key_line| determine_base_line_size(key_line) }.max

    @keyboard.key_lines.map do |key_line|
      "|| " + adjust_and_build_line(target_line_size, key_line) + " ||"
    end
  end

  private

  def determine_base_line_size(key_line)
    build_line(key_line).length
  end

  def adjust_and_build_line(target_line_size, key_line)
    difference = target_line_size - determine_base_line_size(key_line)

    if difference > 0
      key_indices_by_key_length =
        key_line
          .map.with_index { |key, index| [key.command.length, index] }
          .sort
          .reverse
          .map(&:last)

      difference.times do |count|
        index = count % key_indices_by_key_length.count

        key_line[index].size_adjustment += 1
      end
    end

    build_line(key_line)
  end

  def build_line(key_line)
    key_line.map do |key|
      center(key.command, key.adjusted_size(@unit_length))
    end.join(' | ')
  end

  def center(content, size)
    available_size = size - content.length

    padding_left = padding_right = (available_size / 2).to_i # Rounds down
    padding_left +=1 if available_size.odd? # Add the two halves to the left side

    ' ' * padding_left + content + ' ' * padding_right
  end

  def old_determine_base_line_size(key_line)
    size_from_keys = key_line.map { |key| key.adjusted_size(@unit_length) }.sum

    delimiter_count = key_line.count - 1 # eg. KEY_A | KEY_B
    size_from_delimiters = delimiter_count * 3 # two spaces + delim

    size_from_keys + size_from_delimiters
  end

end

Main.run

