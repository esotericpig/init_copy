# encoding: UTF-8
# frozen_string_literal: true

require_relative 'lib/init_copy/version'

Gem::Specification.new do |spec|
  spec.name        = 'init_copy'
  spec.version     = InitCopy::VERSION
  spec.authors     = ['Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['MIT']
  spec.homepage    = 'https://github.com/esotericpig/init_copy'
  spec.summary     = 'Easily use the correct clone or dup method in initialize_copy.'
  spec.description = spec.summary

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri'          => 'https://github.com/esotericpig/init_copy',
    'source_code_uri'       => 'https://github.com/esotericpig/init_copy',
    'bug_tracker_uri'       => 'https://github.com/esotericpig/init_copy/issues',
    'changelog_uri'         => 'https://github.com/esotericpig/init_copy/blob/main/CHANGELOG.md',
  }

  # - https://www.ruby-lang.org/en/downloads/branches/
  spec.required_ruby_version = '>= 3.0'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'
  spec.executables           = []

  spec.extra_rdoc_files = %w[LICENSE.txt README.md]
  spec.rdoc_options     = [
    %w[--embed-mixins --hyperlink-all --line-numbers --show-hash],
    '--main','README.md',
    '--title',"InitCopy v#{InitCopy::VERSION}",
  ].flatten

  spec.files = [
    Dir.glob("{#{spec.require_paths.join(',')}}/**/*.{erb,rb}"),
    Dir.glob("#{spec.bindir}/*"),
    Dir.glob('{spec,test}/**/*.{erb,rb}'),
    %W[Gemfile #{spec.name}.gemspec Rakefile .rdoc_options],
    spec.extra_rdoc_files,
  ].flatten
end
