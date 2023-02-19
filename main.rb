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
LOCAL = ARGV[0]
TARGET = ARGV[1]

zip_file = compress(LOCAL, "dist.zip")
# move(DIR, TARGET)
# unCompressfile(DIR, TARGET)
