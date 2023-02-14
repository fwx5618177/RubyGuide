#!/usr/bin/env ruby

require './module_scp'

include SCP

host = ARGV[0]
username = ARGV[1]
pwd = ARGV[2]
local_file = ARGV[3]
remote_file = ARGV[4]

upload_file(host, username, pwd, local_file, remote_file)
