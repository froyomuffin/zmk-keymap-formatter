# frozen_string_literal: true

module Zmk
  module KeymapFormatter
    class Formatter
      def initialize(keymap_file:)
        @keymap_lines = File.readlines(keymap_file)
        @binding_indices = find_binding_indices
      end

      def format
        @binding_indices.reverse.each do |start, stop|
          raw_rows = @keymap_lines[start..stop]

          keyboard = Keyboard.new(
            layout: Layouts::SIXTY_PERCENT_ANSI,
            raw_rows: raw_rows
          )
          formatted_rows = keyboard.render.map { |row| row + "\n" }

          @keymap_lines[start, raw_rows.length] = formatted_rows
        end

        @keymap_lines
      end

      private

      def find_binding_indices
        binding_pairs = @keymap_lines.map.with_index do |line, index|
          index if (!line.match(/<.*>/) && line.match(/<|>/))
        end.compact.each_slice(2).to_a

        binding_pairs.map { |start, stop| [start + 1, stop - 1] }
      end
    end
  end
end
