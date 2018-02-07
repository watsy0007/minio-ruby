require 'minio-ruby'
require 'open-uri'
 

mc = MinioRuby::MinioClient.new(end_point:"https://s3.amazonaws.com", access_key:"" , secret_key:"", region: "us-east-1" )
puts mc.getObject("mybucket","myimage.png")

file = open("hello.txt").read
#Upload a File.txt
mc.putObject("mybucket", "tfile.txt", file)
#Download  file.txt
mc.getObject("mybucket","tfile.txt")

 
