require 'buildr'

module URI
  class HTTP #:nodoc:
    
    def read(options = nil, &block)
      options ||= {}
      
      user = self.user || options[:username]
      password = self.password || options[:password]
      
      connect do |http|
        trace "Requesting #{self}"
        headers = { 'If-Modified-Since' => CGI.rfc1123_date(options[:modified].utc) } if options[:modified]
        request = Net::HTTP::Get.new(request_uri.empty? ? '/' : request_uri, headers)
        request.basic_auth user, password if user
        
        http.request request do |response|
          case response
            when Net::HTTPNotModified
            # No modification, nothing to do.
            trace 'Not modified since last download'
            return nil
            when Net::HTTPRedirection
            # Try to download from the new URI, handle relative redirects.
            trace "Redirected to #{response['Location']}"
            rself = self + URI.parse(response['Location'])
            rself.user, rself.password = user, password
            return rself.read(options, &block)
            when Net::HTTPOK
            info "Downloading #{self}"
            result = nil
            with_progress_bar options[:progress], path.split('/').last, response.content_length do |progress|
              if block
                response.read_body do |chunk|
                  block.call chunk
                  progress << chunk
                end
              else
                result = ''
                response.read_body do |chunk|
                  result << chunk
                  progress << chunk
                end
              end
            end
            return result
            when Net::HTTPNotFound
            raise NotFoundError, "Looking for #{self} and all I got was a 404!"
          else
            raise RuntimeError, "Failed to download #{self}: #{response.message}"
          end
        end
      end
    end
  end
  
  private
  
  def write_internal(options, &block) #:nodoc:
    options ||= {}
    user = self.user || options[:username]
    password = self.password || options[:password]  
    
    connect do |http|
      trace "Uploading to #{path}"
      content = StringIO.new
      while chunk = yield(RW_CHUNK_SIZE)
        content << chunk
      end
      headers = { 'Content-MD5'=>Digest::MD5.hexdigest(content.string), 'Content-Type'=>'application/octet-stream' }
      request = Net::HTTP::Put.new(request_uri.empty? ? '/' : request_uri, headers)
      
      request.basic_auth user, password if user
      
      response = nil
      with_progress_bar options[:progress], path.split('/').last, content.size do |progress|
        request.content_length = content.size
        content.rewind
        stream = Object.new
        class << stream ; self ;end.send :define_method, :read do |count|
            bytes = content.read(count)
            progress << bytes if bytes
            bytes
          end
          request.body_stream = stream
          response = http.request(request)
        end
        
        case response
          when Net::HTTPRedirection
          # Try to download from the new URI, handle relative redirects.
          trace "Redirected to #{response['Location']}"
          content.rewind
          return (self + URI.parse(response['location'])).write_internal(options) { |bytes| content.read(bytes) }
          when Net::HTTPSuccess
        else
          raise RuntimeError, "Failed to upload #{self}: #{response.message}"
        end
      end
    end
    
  end