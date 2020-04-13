require 'socket'
require 'digest/sha1'
require 'base64'

require_relative 'connection'

module WebSocket
  class Server
    WS_MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    def initialize path: '/', port: 4567, host: 'localhost'
      @path = path
      @tcp_server = TCPServer.new(host, port)
    end

    def accept
      socket = @tcp_server.accept
      send_handshake(socket) && Connection.new(socket)
    end

  private
    def send_handshake socket
      request_line = socket.gets
      header = get_header(socket)
      if (request_line =~ /GET #{@path} HTTP\/1.1/) && (header =~ /Sec-WebSocket-Key: (.*)\r\n/)
        ws_accept = create_websocket_accept($1)
        send_handshake_response(socket, ws_accept)
        return true
      end
      send_400(socket)
      false
    end

    def send_handshake_response socket, ws_accept
      socket << "HTTP/1.1 101 Switching Protocols\r\n" +
        "Upgrade: websocket\r\n" +
        "Connection: upgrade\r\n" +
        "Sec-WebSocket-Accept: #{ws_accept}\r\n"
    end

    def get_header socket, header = ""
      (line = socket.gets) == "\r\n" ? header : get_header(socket, header + line.to_s)
    end

    def send_400(socket)
      socket << "HTTP/1.1 400 Bad Request\r\n" +
        "Content-Type: text/plain\r\n" +
        "Connection: close\r\n" +
        "\r\n" +
        "Incorrect Request"
      socket.close
    end

    def create_websocket_accept key
      digest = Digest::SHA1.digest key + WS_MAGIC_STRING
      Base64.encode64 digest
    end
  end
end
