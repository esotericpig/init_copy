# encoding: UTF-8
# frozen_string_literal: true

require_relative 'lib/init_copy'

Gem::Specification.new do |spec|
  spec.name        = 'init_copy'
  spec.version     = InitCopy::VERSION
  spec.authors     = ['Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['MIT']
  spec.homepage    = 'https://github.com/esotericpig/init_copy'
  spec.summary     = 'Easily use the appropriate clone/dup method in initialize_copy.'
  spec.description = spec.summary

  spec.metadata = {
    'homepage_uri'    => 'https://github.com/esotericpig/init_copy',
    'source_code_uri' => 'https://github.com/esotericpig/init_copy',
    'bug_tracker_uri' => 'https://github.com/esotericpig/init_copy/issues',
    'changelog_uri'   => 'https://github.com/esotericpig/init_copy/blob/main/CHANGELOG.md',
  }

  spec.require_paths = ['lib']

  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{rb}')),
    %W[ Gemfile #{spec.name}.gemspec Rakefile ],
    %w[ LICENSE.txt ],
  ].flatten

  # Lowest version that isn't eol (end-of-life).
  # - https://www.ruby-lang.org/en/downloads/branches/
  spec.required_ruby_version = '>= 3.2'

  spec.add_development_dependency 'bundler' ,'~> 2.2'
  spec.add_development_dependency 'minitest','~> 5.14'
  spec.add_development_dependency 'rake'    ,'~> 13.0'
  spec.add_development_dependency 'yard'    ,'~> 0.9'  # Doc.
end
