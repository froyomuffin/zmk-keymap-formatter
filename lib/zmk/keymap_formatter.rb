# frozen_string_literal: true

require_relative "keymap_formatter/version"

Dir[__dir__ + "/keymap_formatter/**/*.rb"].each do |file|
  require_relative file
end

module KeymapFormatter
  class Error < StandardError; end
end
