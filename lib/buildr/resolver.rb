require 'rubygems'
require 'naether'

module Buildr
  module Resolver
    class << self
      
      def resolver_dependencies
        Naether.bootstrap_dependencies
      end
      
      def resolve( dependencies )
        # Load Naether jar dependencies
        naether_jars = [Naether::Bootstrap.naether_jar]
        naether_jars = naether_jars + Buildr.artifacts(resolver_dependencies).each(&:invoke).map(&:to_s)
        
        naether = Naether.create_from_jars( naether_jars )
        if Buildr.repositories.remote.size > 0
          naether.clear_remote_repositories
          Buildr.repositories.remote.each do |repo|
            naether.add_remote_repository( repo )
          end
        end
        naether.dependencies = dependencies
        naether.resolve_dependencies
        
        naether.dependencies
      end
    end
  end
end