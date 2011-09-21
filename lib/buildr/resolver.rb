require 'rubygems'
require 'naether'
require "buildr/resolver/java"
require "buildr/packaging/repository_array"
require "buildr/override/core/transports"
require "buildr/override/packaging/artifact"

module Buildr
  
  repositories.remote = Buildr::RepositoryArray.new
  
  module Resolver
    class << self
      
      def naether
        Buildr::Resolver::Java.instance.naether
      end
      
      # Resolve dependencies for an array of dependencies in the format of 'groupId:artifactId:type:version'
      # or as a hash to define the scope, 'groupId:artifactId:type:version' => 'compile'. Example:
      #
      # [ 'ch.qos.logback:logback-classic:jar:0.9.24', {'junit:junit:jar:4.8.2' => 'test'} ] 
      #
      # Options
      #   * :excludes - an array of dependencies to regex exclude
      #   * :download - have Buildr::Resolver download artifacts instead of Buildr
      def resolve( dependencies, opts = {} )
        
        options = opts
        
        if Buildr.repositories.remote.size > 0
          naether.clear_remote_repositories
          
          # ensure repos have been converted to RepostoryArray
          Buildr.repositories.remote = Buildr.repositories.remote
          
          Buildr.repositories.remote.each do |repo|
            begin
              naether.add_remote_repository( repo[:url].to_s, repo[:username], repo[:password] ) 
            rescue
              
            end
          end          
        end
        
        naether.local_repo_path = Repositories.instance.local
        
        naether.dependencies = dependencies
        naether.resolve_dependencies( opts[:download] == true )
        
        unless options[:excludes].nil?
          
          excludes = options[:excludes]
          
          unless excludes.is_a? Array
            excludes = [excludes]
          end
          
          dependencies = naether.dependencies
          dependencies.delete_if do |dep|
            excludes.select do |exclude| 
              dep.toString() =~ /^#{exclude}/
            end.size > 0
          end
          
          naether.dependencies = dependencies
          
        end
        
        naether.dependenciesNotation
      end
      
      def deps_from_pom( pom_path, scope=nil )
        naether.pom_dependencies( pom_path, scope )
      end
      
      def pom_version( pom_path )
        naether.pom_version( pom_path )
      end
      
      def write_pom( notation, file_path )
        naether.write_pom( notation, file_path )
      end
      
      def deploy_artifact( notation, file_path, url, opts = {} )
        naether.deploy_artifact( notation, file_path, url, opts )
      end
      
      def install_artifact( notation, file_path, opts = {} )
        naether.install_artifact( notation, file_path, opts )
      end
      
    end
  end
end