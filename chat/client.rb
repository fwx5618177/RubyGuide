#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

require "socket"

server_host = 'localhost'
server_port = 3000

client = TCPSocket.open(server_host, server_port)
puts "Connected to server #{server_host}:#{server_port}"

loop do
    print "Enter msg:"
    msg = gets.chomp

    client.puts(msg)

    recv = client.gets.chomp
    puts recv
end

client.close