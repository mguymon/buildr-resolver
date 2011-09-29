# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{buildr-resolver}
  s.version = "0.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Guymon"]
  s.date = %q{2011-09-29}
  s.description = %q{Java dependency resolver  for Buildr using Maven's Aether}
  s.email = %q{michael.guymon@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "buildr-resolver.gemspec",
    "lib/buildr/override/core/transports.rb",
    "lib/buildr/override/packaging/artifact.rb",
    "lib/buildr/packaging/repository_array.rb",
    "lib/buildr/resolver.rb",
    "lib/buildr/resolver/java.rb",
    "spec/repository_array_spec.rb",
    "spec/resolver_spec.rb"
  ]
  s.homepage = %q{http://github.com/mguymon/buildr-resolver}
  s.licenses = ["Apache"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{buildr-resolver}
  s.rubygems_version = %q{1.5.1}
  s.summary = %q{Java dependency resolver for Buildr using Maven's Aether}
  s.test_files = [
    "spec/repository_array_spec.rb",
    "spec/resolver_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<naether>, ["~> 0.4.4"])
      s.add_runtime_dependency(%q<buildr>, ["~> 1.4.6"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
    else
      s.add_dependency(%q<naether>, ["~> 0.4.4"])
      s.add_dependency(%q<buildr>, ["~> 1.4.6"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    end
  else
    s.add_dependency(%q<naether>, ["~> 0.4.4"])
    s.add_dependency(%q<buildr>, ["~> 1.4.6"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
  end
end

