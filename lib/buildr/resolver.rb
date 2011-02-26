require 'naether'

module Buildr
  module Resolver
    class << self
      
      def resolver_dependencies
        Naether.bootstrap_dependencies.to_a
      end
      
      def resolve( dependencies )
        # Load Naether jar dependencies
        naether_classpath = Buildr.artifacts(resolver_dependencies).each(&:invoke).map(&:to_s)
        naether_classpath.each do |jar|
          require jar
        end
        
        naether = Naether.new
        naether.dependencies = dependencies
        naether.resolve_dependencies
        
        naether.dependencies
      end
    end
  end
end