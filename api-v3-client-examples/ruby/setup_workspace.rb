# setup_workspace.rb
#
# Purpose: Generation of Ruby based API client for the Rapid7 Nexpose and InsightVM v3 API
#
# Requirements: Java install and on PATH
#
# Configuration: Update CONSOLE_URL parameter with appropriate value
#
# Output: Generation of api and models based on Rapid7 Nexpose and InsightVM Swagger file
#

require 'fileutils'
require 'json'
require 'net/http'
require 'net/https'

CONSOLE_URL = 'https://localhost:3780'
CODEGEN_JAR_NAME = 'swagger-codegen-cli'
CODEGEN_JAR_VERSION = '2.3.0'

# Download swagger codegen jar
uri = URI("http://central.maven.org/maven2/io/swagger/#{CODEGEN_JAR_NAME}/#{CODEGEN_JAR_VERSION}/#{CODEGEN_JAR_NAME}-#{CODEGEN_JAR_VERSION}.jar")

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new uri

  http.request request do |response|
    open "#{CODEGEN_JAR_NAME}-#{CODEGEN_JAR_VERSION}.jar", 'w' do |io|
      response.read_body do |chunk|
        io.write chunk
      end
    end
  end
end

# Download swagger file
console_swagger_path = "#{CONSOLE_URL}/api/3/json"
swagger_file = 'console-swagger.json'

uri = URI(console_swagger_path)

Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
  request = Net::HTTP::Get.new uri

  http.request request do |response|
    open swagger_file, 'w' do |io|
      response.read_body do |chunk|
        io.write chunk
      end
    end
  end
end

# Remove previous directories from generation
dirs = %w(lib docs spec)

dirs.each do |dir|
  FileUtils.rm_rf(dir)
end

# Generate library
system("java -jar #{CODEGEN_JAR_NAME}-#{CODEGEN_JAR_VERSION}.jar generate -i #{swagger_file} -l ruby -o ./ -c config.json")
