require 'aws-sdk'

s3 = Aws::S3::Resource.new

s3.bucket('bucket.tools.something.co.uk').object('index.html').upload_file('generated_files/index.html')
s3.bucket('bucket.tools.something.co.uk').object('index.html').acl.put({ acl: "public-read" })

puts "Enjoy! ^__^ "
