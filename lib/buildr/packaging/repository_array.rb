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

module Buildr
  # Extention of Array to standardize URLs into { :url => 'url', :username => 'username', :password => 'password' }.
  #   :url = url of remote repository
  #   :username = optional username for authentication
  #   :password = optional password for authentication
  class RepositoryArray < Array
    
    def initialize( *args )
      if !args.nil? && args.is_a?(Array) && args.size == 1
        args = args[0]
        converted = args.map {|url| convert_remote_url(url) }
        super(converted)
      else
        super(args)
      end
    end
    
    # Concatenation—Returns a new array built by concatenating the two arrays together to produce a third array of standardized URL Hashes.  
    def +(urls)
      concat(urls)      
    end
    
    # Append—Pushes the given object on to the end of this array, as a standardize URL Hash. This expression returns the array itself, so several appends may be chained together. 
    def <<(url)
      converted = convert_remote_url( url )
      super( converted )
    end
    
    # Appends the elements in other_array to self, as standardized URL Hashes    
    def concat(urls)
      if !urls.nil?
        converted = urls.map { |url| convert_remote_url( url ) }
        super(converted)
      else
        super(nil)
      end 
    end
    
    # :call-seq:
    #   url = url => hash
    #   url = Hash => hash
    #
    # With a String url, returns a standardize URL Hash. 
    #
    # With a Hash argument { :url => 'url', :username => 'username', :password => 'password' }, returns a standardize URL Hash.    
    #
    def convert_remote_url(url)
      if url.is_a? String
        return {:url =>  URI.parse(url)}
      elsif url.is_a? Hash
        hash = { :url =>  URI.parse((url[:url] || url['url'])) }
        username = url[:username] || url['username']
        hash[:username] = username if username
        
        password = (url[:password] || url['password'])
        hash[:password] = password if password
        
        return hash
      elsif url.is_a? URI
        return { :url => url }
      else
        raise ArgumentError, "Unsupported :url, must be String, Hash, or URI: #{url.inspect}"
      end
    end
    
    # Inserts the given values before the element with the given index (which may be negative), as standardized URL Hashes
    def insert( index, *args)
      if !args.nil?
        pos = index
        args.each do |url| 
          convert = convert_remote_url( url )
          super( pos, convert )
          if index >= 0
            pos = pos + 1          
          end
        end
      else
        super( index, nil )  
      end
    end
    
    # Replaces the contents of self with the contents of other_array, truncating or expanding if necessary. The contents of other_array
    # is converted standardized URL Hashes.
    def replace( other_array )
      if !other_array.nil?
        converted = other_array.map { |url| convert_remote_url( url ) }
        super( converted )
      else
        super( nil )  
      end
    end
  end
end