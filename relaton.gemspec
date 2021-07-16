# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton"
  spec.version       = Relaton::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "The Relaton core for importing, managing and caching "\
                       "bibliographic references to technical standards."
  spec.description   = <<~DESCRIPTION
      The Relaton core for importing, managing and caching bibliographic
    references to technical standards in the Relaton/XML bibliographic
    model.

    This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/relato/relaton"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  # spec.add_dependency "algoliasearch"
  spec.add_dependency "relaton-bipm", "~> 1.8.0"
  spec.add_dependency "relaton-bsi", "~> 1.8.0"
  spec.add_dependency "relaton-calconnect", "~> 1.8.0"
  spec.add_dependency "relaton-cen", "~> 1.8.pre1"
  spec.add_dependency "relaton-cie", "~> 1.8.0"
  spec.add_dependency "relaton-ecma", "~> 1.8.0"
  spec.add_dependency "relaton-gb", "~> 1.8.0"
  spec.add_dependency "relaton-iec", ">= 1.8.0"
  spec.add_dependency "relaton-ieee", "~> 1.8.0"
  spec.add_dependency "relaton-ietf", "~> 1.8.0"
  spec.add_dependency "relaton-iho", "~> 1.8.0"
  spec.add_dependency "relaton-iso", ">= 1.8.0"
  spec.add_dependency "relaton-itu", ">= 1.8.1"
  spec.add_dependency "relaton-nist", ">= 1.8.0"
  spec.add_dependency "relaton-ogc", "~> 1.8.0"
  spec.add_dependency "relaton-omg", "~> 1.8.0"
  spec.add_dependency "relaton-un", "~> 1.8.0"
  spec.add_dependency "relaton-w3c", "~> 1.8.0"

  spec.add_development_dependency "byebug", "~> 11.0"
  # spec.add_development_dependency "debase"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry-byebug", "~> 3.9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 1.17.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.11.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.10.0"
  # spec.add_development_dependency "ruby-debug-ide"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "vcr", "~> 5"
  spec.add_development_dependency "webmock"
end
