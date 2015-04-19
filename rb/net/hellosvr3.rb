require 'socket'

server = TCPServer.new 2000
loop do 
	Thread.start(server.sysaccept) do |client|
		fd = IO.for_fd(client)
  	while line = client.gets
			puts line
		end
		client.close
	end
end



