require 'lib/buildr/resolver'
require 'buildr'

describe Buildr::Resolver do
  context "Module" do
    it "should resolve dependencies" do
      dependencies = Buildr::Resolver.resolve( ['ch.qos.logback:logback-classic:jar:0.9.24'] )
      
      dependencies.should eql ["ch.qos.logback:logback-classic:jar:0.9.24", "ch.qos.logback:logback-core:jar:0.9.24", "org.slf4j:slf4j-api:jar:1.6.0"]
    end
  end
end