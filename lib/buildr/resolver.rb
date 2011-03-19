require 'rubygems'
require 'naether'
require "#{File.dirname(__FILE__)}/resolver/java"

module Buildr
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
      def resolve( dependencies, opts = {} )
        
        options = opts
        
        if Buildr.repositories.remote.size > 0
          naether.clear_remote_repositories
          Buildr.repositories.remote.each do |repo|
            naether.add_remote_repository( repo[:url].to_s, repo[:username], repo[:password] )           
          end          
        end
        
        naether.local_repo_path = Repositories.instance.local
        
        naether.dependencies = dependencies
        naether.resolve_dependencies( false )
        
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
      
      def deploy_artifact( notation, file_path, url, opts = {} )
        naether.deploy_artifact( notation, file_path, url, opts )
      end
      
      def install_artifact( notation, file_path, opts = {} )
        naether.install_artifact( notation, file_path, opts )
      end
      
      def write_pom( notation, file_path )
        naether.write_pom( notation, file_path )
      end
    end
  end
end