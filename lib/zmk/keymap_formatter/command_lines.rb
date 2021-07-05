# frozen_string_literal: true

module Zmk
  module KeymapFormatter
    class CommandLines
      LEFT_PADDING = ' ' * 3
      def self.for(rows)
        rows
          .map(&:render)
          .map { |line| line.prepend(LEFT_PADDING) }
          .map { |line| line.rstrip }
      end
    end
  end
end
