# frozen_string_literal: true

require_relative "lib/zmk/keymap_formatter/version"

Gem::Specification.new do |spec|
  spec.name          = "zmk-keymap_formatter"
  spec.version       = Zmk::KeymapFormatter::VERSION
  spec.authors       = ["Tom Wang"]
  spec.email         = ["me@tom.af"]

  spec.summary       = "Small util to format zmk keymaps"
  spec.homepage      = "https://tom.af"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/froyomuffin/zmk-keymap-formatter"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "irb"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
