# frozen_string_literal: true

module Zmk
  module KeymapFormatter
    class Row
      attr_reader :keys

      KEY_SEPERATOR = ' ' * 3
      KEY_SEPERATOR_WITH_DELIM = ' | '

      def initialize(row:, row_layout:)
        @keys = row.zip(row_layout).map do |key_data, unit_width|
          Key.new(value: key_data, unit_width: unit_width)
        end
      end

      def delimiter_postions
        delimited_keys = render_keys.join(KEY_SEPERATOR_WITH_DELIM)

        (0..delimited_keys.length - 1).find_all { |index| delimited_keys[index] == '|' }
      end

      def render
        render_keys.join(KEY_SEPERATOR)
      end

      def adjust_characters_per_unit_to(characters_per_unit)
        @keys.each { |key| key.update_character_width_with(characters_per_unit) }
      end

      def adjust_character_width_to(target_width)
        difference = target_width - character_width

        if difference > 0
          keys_by_length_indices = @keys.map.with_index{ |key, index| [key.character_width, index] }
            .sort
            .reverse
            .map(&:last)

          difference.times do |count|
            target_key_index = count % keys_by_length_indices.count

            @keys[target_key_index].increase_character_width(1)
          end
        end
      end

      def character_width
        render_keys.join(KEY_SEPERATOR).length
      end

      private

      def render_keys
        @keys.map(&:render)
      end
    end
  end
end
