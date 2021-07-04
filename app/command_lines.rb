require 'rubygems'
require 'bundler/setup'

class CommandLines
  LEFT_PADDING = ' ' * 3
  def self.for(rows)
    rows.map(&:render).map { |line| line.prepend(LEFT_PADDING) }
  end
end
