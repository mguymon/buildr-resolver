# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

require 'buildr'
require 'buildr/packaging/repository_array'


module Buildr

  # A file task referencing an artifact in the local repository.
  #
  # This task includes all the artifact attributes (group, id, version, etc). It points
  # to the artifact's path in the local repository. When invoked, it will download the
  # artifact into the local repository if the artifact does not already exist.
  #
  # Note: You can enhance this task to create the artifact yourself, e.g. download it from
  # a site that doesn't have a remote repository structure, copy it from a different disk, etc.
  class Artifact 

  protected

    # :call-seq:
    #   download
    #
    # Downloads an artifact from one of the remote repositories, and stores it in the local
    # repository. Raises an exception if the artifact is not found.
    #
    # This method attempts to download the artifact from each repository in the order in
    # which they are returned from #remote, until successful.
    def download
      trace "Downloading #{to_spec}"
      remote = Buildr.repositories.remote
      remote = remote.each { |repo| repo[:url].path += '/' unless repo[:url].path[-1] == '/' }
      fail "Unable to download #{to_spec}. No remote repositories defined." if remote.empty?
      exact_success = remote.find do |repo|        
        begin
          path = "#{group_path}/#{id}/#{version}/#{File.basename(name)}"          
          download_artifact(repo[:url] + path, repo)
          true
        rescue URI::NotFoundError
          false
        rescue Exception=>error
          info error
          trace error.backtrace.join("\n")
          false
        end
      end

      if exact_success
        return
      elsif snapshot?
        download_m2_snapshot(remote)
      else
        fail_download(remote)
      end
    end

    def download_m2_snapshot(repos)
      repos.find do |repo|
        snapshot_url = current_snapshot_repo_url(repo)
        if snapshot_url
          begin
            download_artifact snapshot_url
            true
          rescue URI::NotFoundError
            false
          end
        else
          false
        end
      end or fail_download(repos)
    end

    def current_snapshot_repo_url(repo)
      begin
        metadata_path = "#{group_path}/#{id}/#{version}/maven-metadata.xml"
        metadata_xml = StringIO.new
        URI.download repo[:url] + metadata_path, metadata_xml
        metadata = REXML::Document.new(metadata_xml.string).root
        timestamp = REXML::XPath.first(metadata, '//timestamp')
        build_number = REXML::XPath.first(metadata, '//buildNumber')
        error "No timestamp provided for the snapshot #{to_spec}" if timestamp.nil?
        error "No build number provided for the snapshot #{to_spec}" if build_number.nil?
        return nil if timestamp.nil? || build_number.nil?
        snapshot_of = version[0, version.size - 9]
        repo[:url] + "#{group_path}/#{id}/#{version}/#{id}-#{snapshot_of}-#{timestamp.text}-#{build_number.text}.#{type}"
      rescue URI::NotFoundError
        nil
      end
    end

    def fail_download(repos)
      fail "Failed to download #{to_spec}, tried the following repositories:\n#{repos.map{ |repo| "#{repo[:url].to_s}#{' as ' + repo[:username] if repo[:username]}" }.join("\n")}"
    end

  private

    # :call-seq:
    #   download_artifact
    #
    # Downloads artifact from given repository,
    # supports downloading snapshot artifact with relocation on succeed to local repository
    def download_artifact(path, opts = {})
      download_file = "#{name}.#{Time.new.to_i}"
      begin
        URI.download path, download_file, opts
        if File.exist?(download_file)
          FileUtils.mkdir_p(File.dirname(name))
          FileUtils.mv(download_file, name)
        end
      ensure
        File.delete(download_file) if File.exist?(download_file)
      end
    end

    # :call-seq:
    #   :download_needed?
    #
    # Validates whether artifact is required to be downloaded from repository
    def download_needed?(task)
      return true if !File.exist?(name)

      if snapshot?
        return false if offline? && File.exist?(name)
        return true if update_snapshot? || old?
      end

      return false
    end


  end

  # Holds the path to the local repository, URLs for remote repositories, and settings for release server.
  #
  # You can access this object from the #repositories method. For example:
  #   puts repositories.local
  #   repositories.remote << 'http://example.com/repo'
  #   repositories.release_to = 'sftp://example.com/var/www/public/repo'
  class Repositories
    include Singleton


    # :call-seq:
    #   remote = Array
    #   remote = url
    #   remote = nil
    #
    # With a String argument, clears the array and set it to that single URL.
    #
    # With an Array argument, clears the array and set it to these specific URLs.
    #
    # With nil, clears the array.
    def remote=(urls)
      case urls
      when nil then @remote = nil
      when RepositoryArray then @remote = urls
      when Array then @remote = RepositoryArray.new(urls.dup)
      else @remote =  RepositoryArray.new([urls])
      end
    end

  end
end
