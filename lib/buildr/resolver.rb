require 'rubygems'
require 'naether'
require "#{File.dirname(__FILE__)}/resolver/java"

module Buildr
  module Resolver
    class << self
      
      def resolve( dependencies, excludes=[] )
        naether = Naether.create_from_jars( Buildr::Resolver::Java.instance.jar_dependencies )
        if Buildr.repositories.remote.size > 0
          naether.clear_remote_repositories
          Buildr.repositories.remote.each do |repo|
            naether.add_remote_repository( repo )
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
            excludes.select { |exclude| dep =~ /^#{exclude}/ }.size > 0
          end
        end
      end
      
      def deploy_artifact( notation, file_path, url, opts = {} )
        naether = Naether.create_from_jars( Buildr::Resolver::Java.instance.jar_dependencies )
        naether.deploy_artifact( notation, file_path, url )
      end
    end
  end
end