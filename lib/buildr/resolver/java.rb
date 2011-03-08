require 'rubygems'
require 'naether'
require 'singleton'

module Buildr
  module Resolver
    class Java
      include Singleton
      
      def initialize
        # Load Naether jar dependencies
        @naether_jars = [Naether::Bootstrap.naether_jar]
        @naether_jars = @naether_jars + Buildr.artifacts(Naether.bootstrap_dependencies).each(&:invoke).map(&:to_s)
      end
      
      def jar_dependencies
        @naether_jars
      end
    end
  end
end