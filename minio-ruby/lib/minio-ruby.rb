require "net/http"
require "net/https"
require "base64"
require "openssl"
require 'uri'
require "minio-ruby/signer"
require "minio-ruby/digest"
require 'digest'

module MinioRuby
  class MinioClient
    attr_accessor :end_point, :port, :access_key, :secret_key,
                  :secure, :transport, :region, :debug

    def initialize(params = {})
      # TODO: add extensive error checking of params here.
      params[:debug] = params[:debug] ? params[:debug] : false
      params.each { |key, value| send "#{key}=", value }
    end

    def get_object(bucket_name, object_name)
      url = "#{end_point}/#{bucket_name}/#{object_name}"
      headers = sign_headers url

      uri = URI.parse(end_point)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = secure

      req = Net::HTTP::Get.new(url, headers)
      req.body = ''
      https.set_debug_output($stdout) if debug
      https.request(req)
    end


    def put_object(bucket_name, object_name, data)
      url = "#{end_point}/#{bucket_name}/#{object_name}"
      headers = sign_headers url, data
      uri = URI.parse(end_point)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = secure

      req = Net::HTTP::Put.new(url, headers)
      req.body = data
      https.set_debug_output($stdout) if debug
      https.request(req)
    end


    def bucket_exists(bucket_name); end


    def fput_object(bucket_name, object_name, file_path, content_type); end

    def make_bucket(bucket_name)
      url = "#{end_point}/#{bucket_name}"
      headers = sign_headers url
      uri = URI.parse(url)

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = secure

      req = Net::HTTP::Put.new(uri, headers)
      req.body = ''
      https.set_debug_output($stdout) if debug
      response = https.request(req)

      if response.code != '200'
        puts 'Error Making bucket'
      else
        puts 'Made bucket'
      end
    end

    private

    def sign_headers(url, data = '')
      signer = MinioRuby::Signer.new(
        access_key: access_key,
        secret_key: secret_key,
        region: region
      )
      signer.sign_v4('PUT',
                     url,
                     {},
                     data,
                     debug)
    end
  end
end
