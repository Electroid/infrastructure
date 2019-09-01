require 'socket'
require 'uri'

server = TCPServer.new('localhost', 8080)

loop do
  socket       = server.accept
  request_line = socket.gets.split("/")[1].split(" ")[0]

  STDERR.puts request_line

  case request_line.downcase
  when "healtz"
    message = "ok\n"
    socket.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n"

    socket.print "\r\n"

    socket.print message
  else
    File.open("backend.html", "rb") do |file|
      socket.print "HTTP/1.1 404 Not Found\r\n" +
                   "Content-Type: text/html\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Connection: close\r\n"

      socket.print "\r\n"
      IO.copy_stream(file, socket)
    end
  end

  socket.close
end
