# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of InitCopy.
# Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)
# 
# InitCopy is free software: you can redistribute it and/or modify it under
# the terms of the MIT License.
# 
# You should have received a copy of the MIT License along with InitCopy.
# If not, see <https://choosealicense.com/licenses/mit/>.
#++


require 'bundler/gem_tasks'

require 'init_copy'
require 'rake/clean'
require 'rake/testtask'
require 'yard'


CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')


task default: [:test]

desc 'Generate doc (YARDoc)'
task :doc => [:yard] do |task|
end

Rake::TestTask.new() do |task|
  task.libs = ['lib','test']
  task.pattern = File.join('test','**','*_test.rb')
  task.description += ": '#{task.pattern}'"
  task.verbose = false
  task.warning = true
end

YARD::Rake::YardocTask.new() do |task|
  task.files = [File.join('lib','**','*.{rb}')]
  
  task.options += ['--files','CHANGELOG.md,LICENSE.txt']
  task.options += ['--readme','README.md']
  
  task.options << '--protected' # Show protected methods
  #task.options += ['--template-path',File.join('yard','templates')]
  task.options += ['--title',"InitCopy v#{InitCopy::VERSION} Doc"]
end
