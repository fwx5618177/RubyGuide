#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

require "socket"

HOST = 'localhost'
PORT = 3000

server = TCPServer.new(HOST, PORT)

clients = []

puts "Server started on #{HOST}:#{PORT}"

while true
    client = server.accept
    clients << client

    client.puts "Welcome to the chat room! There are #{clients.length} users online."

    Thread.new do
        loop do
            msg = client.gets.chomp

            clients.each do |c|
                next if c == client
                c.puts "#{client.peeraddr[1]}:#{msg}"
            end
        end
    end
end