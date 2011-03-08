require 'rubygems'
require 'naether'
require "#{File.dirname(__FILE__)}/resolver/java"

module Buildr
  module Resolver
    class << self
      
      def naether
        Buildr::Resolver::Java.instance.naether
      end
      
      # Resolve dependencies for an array of dependencies
      #
      # excludes is an array of dependencies to exclude
      # repos is an array of {:url => '', :username => '', :password => '' } of additional remote repos
      # with authentication
      def resolve( dependencies, excludes=[], repos = [] )
        if Buildr.repositories.remote.size > 0
          naether.clear_remote_repositories
          Buildr.repositories.remote.each do |repo|
            naether.add_remote_repository( repo )
          end
          
          unless repos.nil?
            unless repos.is_a? Array
              repos = [repos]
            end
            
            repos.each do |repo|
              naether.add_remote_repository( repo[:url], repo[:username], repo[:password] )
            end
          end
        end
        
        naether.local_repo_path = Repositories.instance.local
        
        naether.dependencies = dependencies
        naether.resolve_dependencies( false )
        
        dependences = naether.dependencies
        
        unless excludes.nil?
          unless excludes.is_a? Array
            excludes = [excludes]
          end
          
          dependences.delete_if do |dep|
            excludes.select { |exclude| dep.to_s =~ /^#{exclude}/ }.size > 0
          end
        end
      end
      
      def deploy_artifact( notation, file_path, url, opts = {} )
        naether.deploy_artifact( notation, file_path, url, opts )
      end
      
      def write_pom( notation, file_path, dependencies, excludes=[], repos = [] )
        naether.write_pom( notation, file_path )
      end
    end
  end
end