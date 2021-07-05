# frozen_string_literal: true

module Zmk
  module KeymapFormatter
    class DecoratorLines
      LEFT_PADDING = '// '

      UL_CORNER = '┌'
      LL_CORNER = '└'
      UR_CORNER = '┐'
      LR_CORNER = '┘'
      H_LINE = '─'
      V_LINE = '│'
      B_DOWN = '┬'
      B_UP = '┴'
      B_LEFT = '┤'
      B_RIGHT = '├'
      B_UP_DOWN = '┼'

      def self.for(rows)
        top_decorator_line = build_top_decorator_line(rows.first)

        row_pairs = rows.each_cons(2).to_a
        middle_decorator_lines = row_pairs.map do |row_a, row_b|
          build_middle_decorator_line(
            row_a,
            row_b
          )
        end

        bottom_decorator_line = build_bottom_decorator_line(rows.last)

        lines = [top_decorator_line] + middle_decorator_lines + [bottom_decorator_line]

        lines.map { |line| line.prepend(LEFT_PADDING) }
      end

      private

      def self.build_top_decorator_line(row)
        character_width = row.character_width
        delimiter_positions = row.delimiter_postions

        character_width.times.map do |index|
          if index == 0
            UL_CORNER
          elsif index == character_width - 1
            UR_CORNER
          elsif delimiter_positions.include?(index)
            B_DOWN
          else
            H_LINE
          end
        end.join
      end

      def self.build_bottom_decorator_line(row)
        character_width = row.character_width
        delimiter_positions = row.delimiter_postions

        character_width.times.map do |index|
          if index == 0
            LL_CORNER
          elsif index == character_width - 1
            LR_CORNER
          elsif delimiter_positions.include?(index)
            B_UP
          else
            H_LINE
          end
        end.join
      end

      def self.build_middle_decorator_line(row_a, row_b)
        character_width = row_a.character_width
        delimiter_positions_a = row_a.delimiter_postions
        delimiter_positions_b = row_b.delimiter_postions

        character_width.times.map do |index|
          if index == 0
            B_RIGHT
          elsif index == character_width - 1
            B_LEFT
          elsif delimiter_positions_a.include?(index) && delimiter_positions_b.include?(index)
            B_UP_DOWN
          elsif delimiter_positions_a.include?(index)
            B_UP
          elsif delimiter_positions_b.include?(index)
            B_DOWN
          else
            H_LINE
          end
        end.join
      end
    end
  end
end
