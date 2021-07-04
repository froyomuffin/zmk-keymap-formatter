require 'rubygems'
require 'bundler/setup'

class Key
  attr_reader :value
  attr_reader :unit_width
  attr_reader :density
  attr_reader :character_width

  def initialize(value:, unit_width:)
    @value = value.prepend('&')
    @unit_width = unit_width
    @density = @value.length / @unit_width
    @character_width = -1
  end

  def update_character_width_with(characters_per_unit)
    @character_width = (@unit_width * characters_per_unit).ceil
  end

  def increase_character_width(amount)
    @character_width += amount
  end

  def render
    available_size = character_width - @value.length

    padding_left = padding_right = (available_size / 2).to_i # Rounds down
    padding_left +=1 if available_size.odd? # Add the two halves to the left side

    ' ' * padding_left + value + ' ' * padding_right
  end
end
