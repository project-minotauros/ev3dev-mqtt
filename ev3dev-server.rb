require 'rubygems'
require 'bundler/setup'

require_relative 'src/websocket/server'

puts "Initializin..."
server = WebSocket::Server.new host: '0.0.0.0'

puts "Ready to accept requests"

loop do
  Thread.new(server.accept) do |connection|
    puts "Connected"
    while (message = connection.receive)
      puts "Received #{message}"
      connection.send("Received #{message}...")
    end
  end
end
