#!/usr/bin/env rake
require "bundler/gem_tasks"

#############################################################################
#
# Helper functions
#
#############################################################################

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

#############################################################################
#
# Standard tasks
#
#############################################################################

desc 'Default: run specs.'
task :default => :spec

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Generate SimpleCov test coverage and open in your browser"
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{InputReader::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/#{name}.rb"
end
