# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'init_copy'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'

CLEAN.exclude('.git/','.github/','.idea/','stock/')
CLOBBER.include('doc/')

task default: %i[test]

Rake::TestTask.new do |task|
  task.libs = ['lib','test']
  task.pattern = 'test/**/*_test.rb'
  task.options = '--pride'
  task.verbose = false
  task.warning = true
end

RDoc::Task.new(:doc) do |task|
  task.rdoc_dir = 'doc'
end
