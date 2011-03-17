require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) 

task :test => :spec

task :default => :test

require 'jeweler'
Jeweler::Tasks.new do |gem|
  
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "buildr-resolver"
  gem.rubyforge_project  = 'buildr-resolver'
  gem.homepage = "http://github.com/mguymon/buildr-resolver"
  gem.license = "Apache"
  gem.summary = %Q{Java dependency resolver for Buildr using Maven's Aether}
  gem.description = %Q{Java dependency resolver  for Buildr using Maven's Aether}
  gem.email = "michael.guymon@gmail.com"
  gem.authors = ["Michael Guymon"]
  gem.require_paths = %w[lib]
  
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new