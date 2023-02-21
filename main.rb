#!/usr/bin/env ruby

require './module_scp'

include SCP

# SCP Upload
# host = ARGV[0]
# username = ARGV[1]
# pwd = ARGV[2]
# local_file = ARGV[3]
# remote_file = ARGV[4]

# upload_file(host, username, pwd, local_file, remote_file)

# Move File
# ruby main.rb "~/Desktop/prompts" "/Volumes/RAID/dev"
# ruby main.rb "~/Desktop/perl/spide/dist" "/Volumes/raid1/r18/img/"
LOCAL = ARGV[0]
TARGET = ARGV[1]

# zip_file = compress(LOCAL, "dist.zip")
thread_compress_entry(LOCAL, "dist.zip", 4)
move("#{LOCAL}/dist.zip", TARGET)
unCompressfile("#{TARGET}/dist.zip", TARGET)
delete_file(LOCAL)