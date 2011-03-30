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
require 'buildr/packaging/repository_array'

describe Buildr::RepositoryArray do
  it 'should create a new instance' do
    repo_array = Buildr::RepositoryArray.new
    repo_array.should_not be_nil
  end
  
  it 'should create a new instance from an array' do
    repo_array = Buildr::RepositoryArray.new( ['url1', {:url => 'url2'}] )
    repo_array[0].should eql( { :url =>  URI.parse('url1') } )
    repo_array[1].should eql( { :url =>  URI.parse('url2') } )
  end
  
  context "instance" do
    before(:each) do
      @array = Buildr::RepositoryArray.new
    end
    
    it 'should << and convert to standardize Hash' do
      @array << 'url1' << { 'url' => 'url2' }
      @array[0].should eql( {:url => URI.parse('url1')} )
      @array[1].should eql( {:url => URI.parse('url2')} )
    end
    
    it 'should + and convert to standardize Hash' do
      @array + ['url1', { :url => 'url2'}]
      @array[0].should eql( {:url => URI.parse('url1')} )
      @array[1].should eql( {:url => URI.parse('url2')} )
      
      @array + ['url3', { :url => 'url4'}]
      @array[0].should eql( {:url => URI.parse('url1')} )
      @array[1].should eql( {:url => URI.parse('url2')} )
      @array[2].should eql( {:url => URI.parse('url3')} )
      @array[3].should eql( {:url => URI.parse('url4')} )
    end
    
     it 'should concat and convert to standardize Hash' do
      @array + ['url1', { :url => 'url2'}]
      @array[0].should eql( {:url => URI.parse('url1')} )
      @array[1].should eql( {:url => URI.parse('url2')} )
      
      @array + ['url3', { :url => 'url4'}]
      @array[0].should eql( {:url => URI.parse('url1')} )
      @array[1].should eql( {:url => URI.parse('url2')} )
      @array[2].should eql( {:url => URI.parse('url3')} )
      @array[3].should eql( {:url => URI.parse('url4')} )
    end            
    
    it 'should convert a String into a standardize Hash' do
      @array.convert_remote_url( 'url' ).should eql( {:url => URI.parse('url') } )
    end
    
    it 'should convert a Hash into a standardize Hash' do
      @array.convert_remote_url({ :username => 'username', :blah => 7, 'password' => 'password', 'foo' => 'bot', 'url' => 'url' }).should eql( {:url => URI.parse('url'), :username => 'username', :password => 'password' } )
    end
    
    it 'should convert a URI into a standardize Hash' do
      @array.convert_remote_url( URI.parse('test')).should eql( {:url => URI.parse('test') } )
    end
    
    it 'Unsupported :url, must be String, Hash, or URI: 7' do
      lambda { @array.convert_remote_url( 7 ) }.should raise_error(ArgumentError, /Unsupported :url, must be String, Hash, or URI: 7/)
    end
    
    it "should insert as standardized Hash" do
      @array << 'url1' << 'url3'
      @array.insert( 1, 'url2', 'url2.5' )
      
      @array[0].should eql( {:url =>  URI.parse('url1')} )
      @array[1].should eql( {:url =>  URI.parse('url2')} )
      @array[2].should eql( {:url =>  URI.parse('url2.5')} )
      @array[3].should eql( {:url =>  URI.parse('url3')} )
      
      @array.insert( -3, 'url2.2', 'url2.3' )
      
      @array[0].should eql( {:url =>  URI.parse('url1')} )
      @array[1].should eql( {:url =>  URI.parse('url2')} )
      @array[2].should eql( {:url =>  URI.parse('url2.2')} )
      @array[3].should eql( {:url =>  URI.parse('url2.3')} )
      @array[4].should eql( {:url =>  URI.parse('url2.5')} )
      @array[5].should eql( {:url =>  URI.parse('url3')} )
    end
    
    it "should replace as standardized Hash" do
      @array << 'test'
      @array.replace( ['url1', 'url2'] )
      
      @array[0].should eql( {:url =>  URI.parse('url1')} )
      @array[1].should eql( {:url =>  URI.parse('url2')} )
    end
  end
end
