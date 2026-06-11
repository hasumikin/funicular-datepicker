# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "funicular-datepicker"
  spec.version = "0.1.1"
  spec.authors = ["HASUMI Hitoshi"]
  spec.email = ["hasumikin@gmail.com"]

  spec.summary = "Date picker component for Funicular"
  spec.description = "A Funicular date picker component packaged as a Ruby-script CRubygem."
  spec.homepage = "https://github.com/hasumikin/funicular-datepicker"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir[
    "assets/**/*",
    "lib/**/*.rb",
    "README.md"
  ].reject { |path| File.directory?(path) }
  spec.require_paths = ["lib"]
end
