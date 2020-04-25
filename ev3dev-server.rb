#!/usr/local/bin/ruby -w

puts "Starting up..."

require 'rubygems'
require 'bundler/setup'

require_relative 'src/websocket/server'
require_relative 'src/message_handler'

puts "Initializing..."
server = WebSocket::Server.new host: '0.0.0.0'

puts "Ready to accept requests"

loop do
  Thread.new(server.accept) do |connection|
    puts "A client has connected"
    handler = MessageHandler.new connection
    while (message = connection.receive)
      puts "Received #{message}"
      connection.send("Received #{message}...")
      handler.decode message
    end
  end
end
