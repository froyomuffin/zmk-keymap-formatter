
class KeyboardConfig
  attr_reader :layers

  def initialize(keymap_config_location)
    @raw_keymap_config = File.readlines(keymap_config_location)

    @include_lines = []
    @binding_opens = []
    @binding_closes = []
    @binding_ranges = []

    parse

    @layers = []

    build
  end

  def parse
    @raw_keymap_config.each_with_index do |line, index|
      next if accumulate_with(line, index, "#include", @include_lines)
      next if accumulate_with(line, index, "<", @binding_opens)
      next if accumulate_with(line, index, ">", @binding_closes)
    end

    @binding_ranges = @binding_opens.zip(@binding_closes).map do |start, stop|
      (start + 1 .. stop - 1)
    end
  end

  def build
    @binding_ranges.map do |range|
      config_lines = @raw_keymap_config[range]

      @layers << Layer.new(config_lines)
    end
  end

  def accumulate_with(line, index, condition, accumulator)
    if line.include?(condition)
      accumulator << index 
      return true
    else
      return false
    end
  end
end

class Layer
  attr_reader :lines

  def initialize(config_lines)
    @lines = []

    config_lines.each do |config_line|
      keys = []
      key_atoms = config_line.split(' ')

      key_atoms.each_with_index do |atom, index|
        next unless Key.is_kind?(atom)

        kind = atom
        value = key_atoms[index + 1] unless Key.requires_no_value?(kind)

        keys << Key.new(kind, value)
      end

      @lines << keys
    end
  end
end

class Key
  attr_reader :kind
  attr_reader :value

  def initialize(kind, value, units = 1)
    @kind = kind
    @value = value
    @units = units
  end

  def to_s
    if kind.nil?
      "#{kind}"
    else
      "#{kind} #{value}"
    end
  end

  def self.is_kind?(string)
    string.include?('&')
  end

  KINDS_REQUIRE_NO_VALUE = %w(
    &trans
    &none
    &reset
    &bootloader
  )
  def self.requires_no_value?(kind)
    KINDS_REQUIRE_NO_VALUE.include?(kind)
  end
end

class Layouts
  SIXTY_PERCENT_ANSI = [
    [1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.00], 
    [1.50, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.50], 
    [1.75, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.25], 
    [2.25, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.75], 
    [1.25, 1.25, 1.25, 6.25, 1.25, 1.25, 1.25, 1.25], 
  ]
end

Main.run

Layouts::SIXTY_PERCENT_ANSI.each do |line|
  puts line.sum
end
