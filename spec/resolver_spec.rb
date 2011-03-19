require 'lib/buildr/resolver'
require 'buildr'
require 'fileutils'

Buildr.application.instance_eval { @rakefile = File.expand_path('buildfile') }

describe Buildr::Resolver do
  context "Module" do
    
    before(:all) do
      unless File.exists? 'tmp/test-repo'
        FileUtils::mkdir_p 'tmp/test-repo'
      end
      
      Buildr::Resolver.naether.local_repo_path = 'tmp/test-repo'
    end
    
    it "should resolve dependencies" do
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'] )
      
      dependencies.should eql ["ch.qos.logback:logback-classic:jar:0.9.24", "ch.qos.logback:logback-core:jar:0.9.24", "org.slf4j:slf4j-api:jar:1.6.0"]
    end
    
    it "should resolve dependencies with exclusions" do
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'], { :excludes => ['ch.qos.logback:logback-classic'] } )
      dependencies.should eql ["ch.qos.logback:logback-core:jar:0.9.24", "org.slf4j:slf4j-api:jar:1.6.0"]
      
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'], { :excludes => ['org.slf4j'] } )
      dependencies.should eql ["ch.qos.logback:logback-classic:jar:0.9.24","ch.qos.logback:logback-core:jar:0.9.24"]
      
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'], { :excludes => ['ch.qos.logback:logback-classic:jar:0.9.24', 'ch.qos.logback:logback-core:jar:0.9.24'] } )
      dependencies.should eql ["org.slf4j:slf4j-api:jar:1.6.0"]
    end
    
    it "should deploy artifact" do
      Buildr::Resolver.deploy_artifact( "test:test:jar:1.12", Naether::Bootstrap.naether_jar, 'file:tmp/test-repo' )
      File.exists?('tmp/test-repo/test/test/1.12/test-1.12.jar').should be_true
    end
    
    it "should write a pom" do
      Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'] )
      Buildr::Resolver.write_pom( "buildr-resolver:buildr-resolver:jar:45.45", "tmp/pom.xml" )
      File.exists?( 'tmp/pom.xml' ).should be_true
      
      xml = IO.read( 'tmp/pom.xml' ) 
      xml.should match /.+ch.qos.logback<\/groupId>\s+<artifactId>logback-core<\/artifactId>\s+<version>0.9.24.+/
      xml.should match /.+org.slf4j<\/groupId>\s+<artifactId>slf4j-api<\/artifactId>\s+<version>1.6.0.+/
      
    end
    
    it "should install a pom" do
      if File.exists?( "#{Buildr::Resolver.naether.local_repo_path}buildr-resolver/11.11/buildr-resolver-11.11.jar" )
        File.delete("#{Buildr::Resolver.naether.local_repo_path}buildr-resolver/11.11/buildr-resolver-11.11.jar")
      end
      
      Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'] )
      Buildr::Resolver.write_pom( "buildr-resolver:buildr-resolver:jar:45.45", "tmp/pom.xml" )
      Buildr::Resolver.install_artifact( "buildr-resolver:buildr-resolver:jar:11.11", Naether::Bootstrap.naether_jar, {:pom_path => "tmp/pom.xml"} )
      File.exists?( "#{Buildr::Resolver.naether.local_repo_path}/buildr-resolver/11.11/buildr-resolver-11.11.jar" )
    end
  end
end