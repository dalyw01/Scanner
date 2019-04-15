# Scanner

[Scanner] is a tool to help find video and audio content with certain properties to be played on SMP.

It reads in multiple JSON feeds, takes the necessary info and prints to a pretty and simplified HTML file.

It's run daily providing fresh video and audio content for testing.

Once completed, Scanner generates a HTML file which is then hosted on an S3 Bucket

## How do I run it?

First clone your own copy from this GitHub repo

Once you've done that, simply run this command from your terminal -

```
ruby run_scanner.rb
```

Once that's finished you should see this file has been generated!

```
index.html
```

## What do I need to view the results?

To see the results simply view [index.html] through your browser!

## What do I need to work on it?

To run it, you need Ruby installed on your local machine.

## What version of ruby?

```
ruby 2.3.1
```

## How do I upload Scanner?

Upload [index.html] onto an S3 bucket via the AWS console

## Is there a quicker way to upload!?

Yes there is!

If you have the AWS CLI installed with the following version

```
aws --version
aws-cli/1.11.90 Python/2.7.13 Darwin/14.5.0 botocore/1.5.53
```

And a valid aws config (that has permissions to the bucket in question)

NOTE : This is just an example of what you'd need to configure, this is not a valid config!

```
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: ENTER
```

Then you can simply run the script **upload_scanner.rb**

```
ruby upload_scanner.rb
```

## Author

william.daly@bbc.co.uk
