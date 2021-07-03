require 'rubygems'
require 'bundler/setup'

class Main
  SAMPLE_LAYER = "samples/layer.keymap"

  def self.run
    puts "Starting"

    key_lines = File.readlines(SAMPLE_LAYER)
    kb = Keyboard.new(key_lines)

    human_builder = HumanLayoutBuilder.new(kb.key_lines)
    config_builder = ConfigLayoutBuilder.new(kb.key_lines)

    puts human_builder.build
    puts "------"
    puts config_builder.build
  end
end

class Keyboard
  attr_reader :key_lines

  def initialize(key_lines)
    @raw_key_lines = key_lines.map do |line|
      line
        .split('&')
        .map(&:strip)
        .reject(&:empty?)
        .map do |key|
          key.gsub(/\s+/, " ")
        end
    end

    @key_lines = Layouts.apply_layout(@raw_key_lines, Layouts::SIXTY_PERCENT_ANSI)
    @key_lines = @key_lines.map do |key_line|
      key_line.map do |key_data, unit_size|
        Key.new(key_data, unit_size)
      end
    end
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

  def self.apply_layout(key_lines, layout)
    raise "Layout doesn't match!" unless verify(key_lines, layout)

    key_lines.each_with_index.map do |line, index|
      line.zip(layout[index])
    end
  end

  def self.verify(key_lines, layout)
    key_lines.map(&:count) == layout.map(&:count)
  end
end

class Key
  attr_reader :kind
  attr_reader :value
  attr_reader :size

  def initialize(key_data, size)
    @kind, @value = key_data.split(' ')
    @size = size
  end
end

class BaseLayoutBuilder
  def initialize(key_lines)
    @key_lines = key_lines
    @densest_key = @key_lines.flatten.max do |key_a, key_b|
      unit_size_a = (value_for(key_a).length + 2)/key_a.size
      unit_size_b = (value_for(key_b).length + 2)/key_b.size
      
      unit_size_a <=> unit_size_b
    end

    @unit_size = ((value_for(@densest_key).length + 2) / @densest_key.size)
  end

  private

  def format_key(key)
    target_size = (@unit_size * key.size).to_i * @size_multiplier
    value = value_for(key)

    padding_size = target_size - value.length

    left_padding_size = (padding_size / 2).to_i
    right_padding_size = padding_size.to_i - left_padding_size

    ' ' * left_padding_size + value + ' ' * right_padding_size
  end
end

class ConfigLayoutBuilder < BaseLayoutBuilder
  def initialize(key_lines)
    @size_multiplier = 1
    super(key_lines)
  end

  def build
    payload = @key_lines.map do |key_line|
      key_line.map do |key|
        format_key(key)
      end.join
    end.join("\n")
  end

  private

  def value_for(key)
    if key.value.nil?
      "&#{key.kind}"
    else
      "&#{key.kind} #{key.value}"
    end
  end
end

class HumanLayoutBuilder < BaseLayoutBuilder
  def initialize(key_lines)
    @size_multiplier = 1
    super(key_lines)
  end

  def build
    payload = @key_lines.map do |key_line|
      '// |' + key_line.map do |key|
        format_key(key) + '|'
      end.join
    end.join("\n")
  end

  private

  def value_for(key)
    case key.kind
    when 'mo'
      value_for_modifier(key)
    when 'kp'
      MAPPING.dig(
        key.kind.to_sym,
        key.value.to_sym,
      ) || 'UNDEF'
    else
      'UNDEF'
    end
  end

  def value_for_modifier(key)
    "MO(#{key.value})"
  end

  MAPPING = {
    kp: {
      ESC: 'ESC',
      N1: '1',
      N2: '2',
      N3: '3',
      N4: '4',
      N5: '5',
      N6: '6',
      N7: '7',
      N8: '8',
      N9: '9',
      N0: '0',
      MINUS: '-',
      EQUAL: '=',
      BSPC: 'BKSP',
      TAB: 'TAB',
      Q: 'Q',
      W: 'W',
      E: 'E',
      R: 'R',
      T: 'T',
      Y: 'Y',
      U: 'U',
      I: 'I',
      O: 'O',
      P: 'P',
      LBKT: '[',
      RBKT: ']',
      BSLH: '\\',
      A: 'A',
      S: 'S',
      D: 'D',
      F: 'F',
      G: 'G',
      H: 'H',
      J: 'J',
      K: 'K',
      L: 'L',
      SEMI: ';',
      SQT: '\'',
      RET: 'ENTER',
      LSHFT: 'SHIFT',
      Z: 'Z',
      X: 'X',
      C: 'C',
      V: 'V',
      B: 'B',
      N: 'N',
      M: 'M',
      COMMA: ',',
      DOT: '.',
      FSLH: '/',
      UP: 'UP',
      LCTRL: 'CTL',
      LALT: 'ALT',
      LGUI: 'CMD',
      SPACE: 'SPACE',
      LEFT: 'LEFT',
      DOWN: 'DOWN',
      RIGHT: 'RIGHT',
    },
    mo: {},
    bt: {},
    none: {},
    trans: {},
  }
end


Main.run
