require 'lib/buildr/resolver'
require 'buildr'
require 'fileutils'

Buildr.application.instance_eval { @rakefile = File.expand_path('buildfile') }

describe Buildr::Resolver do
  context "Module" do
    it "should resolve dependencies" do
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'] )
      
      dependencies.should eql ["ch.qos.logback:logback-classic:jar:0.9.24", "ch.qos.logback:logback-core:jar:0.9.24", "org.slf4j:slf4j-api:jar:1.6.0"]
    end
    
    it "should resolve dependencies with exclusions" do
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'], ['ch.qos.logback:logback-classic'] )
      dependencies.should eql ["ch.qos.logback:logback-core:jar:0.9.24", "org.slf4j:slf4j-api:jar:1.6.0"]
      
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'], ['org.slf4j'] )
      dependencies.should eql ["ch.qos.logback:logback-classic:jar:0.9.24","ch.qos.logback:logback-core:jar:0.9.24"]
      
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'], ['ch.qos.logback:logback-classic:jar:0.9.24', 'ch.qos.logback:logback-core:jar:0.9.24'] )
      dependencies.should eql ["org.slf4j:slf4j-api:jar:1.6.0"]
    end
    
    it "should deploy artifact" do
      unless File.exists? 'tmp/test-repo'
        FileUtils::mkdir_p 'tmp/test-repo'
      end
      
      Buildr::Resolver.deploy_artifact( "test:test:jar:1.12", Naether::Bootstrap.naether_jar, 'file:tmp/test-repo' )
      File.exists?('tmp/test-repo/test/test/1.12/test-1.12.jar').should be_true
    end
  end
end