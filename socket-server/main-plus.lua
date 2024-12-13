local socket = require("socket")  -- Import LuaSocket
local ffi = require("ffi")        -- Import FFI to call C functions

-- Declare the required system calls and constants using LuaJIT FFI
ffi.cdef[[
    int setsockopt(int sockfd, int level, int optname, const void *optval, int optlen);
]]

-- TCP socket options (these are the Linux constants)
local IPPROTO_TCP = 6           -- Protocol number for TCP (from /etc/protocols)
local TCP_QUICKACK = 12         -- Option code for TCP_QUICKACK (from <netinet/tcp.h>)

-- Create a TCP socket and bind it to the local host, port 8080
local server = assert(socket.bind("*", 8080)) -- Binds to all IP addresses (*), port 8080
local ip, port = server:getsockname()

print("Server started on IP: " .. ip .. ", Port: " .. port)

-- Disable TCP_QUICKACK on the server's file descriptor
-- We use the FFI to extract the file descriptor (FD) from LuaSocket
local fd = server:getfd() and server:getfd() or server:getfd()
if not fd then
    error("Could not extract file descriptor from LuaSocket")
end

-- Disable TCP_QUICKACK (0 = disabled)
local flag = ffi.new("int[1]", 0) -- Array of 1 integer (C-style)
local result = ffi.C.setsockopt(fd, IPPROTO_TCP, TCP_QUICKACK, flag, ffi.sizeof(flag))
if result ~= 0 then
    error("Failed to disable TCP_QUICKACK")
else
    print("Successfully disabled TCP_QUICKACK")
end

-- Set the server to non-blocking mode (optional)
server:settimeout(0)

while true do
    -- Use socket.select to handle the server's accept method
    local ready = socket.select({server}, nil, 0.1)  -- Use 0.1s timeout to avoid high CPU usage
    -- If the server socket is ready to accept a client connection
    if ready and #ready > 0 then
        local client = server:accept()
        if client then
            print("New client connected")
            -- Extract the file descriptor for the client socket
            local client_fd = client:getfd() and client:getfd() or client:getfd()
            if client_fd then
                -- Disable TCP_QUICKACK on the client socket as well
                local result = ffi.C.setsockopt(client_fd, IPPROTO_TCP, TCP_QUICKACK, flag, ffi.sizeof(flag))
                if result ~= 0 then
                    print("Failed to disable TCP_QUICKACK for client")
                else
                    print("Disabled TCP_QUICKACK for client connection")
                end
            end
            -- Set client socket to blocking mode to receive messages
            client:settimeout(10) -- Timeout for read() and receive() operations (in seconds)
            -- Receive data from the client
            while true do
                local data, err = client:receive()
                if data then
                    print("Received from client: " .. data)
                    -- Echo the message back to the client
                    local success, send_err = client:send("Echo: " .. data .. "\n")
                    if not success then
                        print("Send error: " .. send_err)
                        break
                    end
                elseif err == "timeout" then
                    print("Client timeout")
                    break
                elseif err == "closed" then
                    print("Client closed the connection")
                    break
                else
                    print("Receive error: " .. err)
                    break
                end
            end
            -- Close the client connection after processing
            client:close()
            print("Client connection closed.")
        end
    end
    -- (Optional) Add a small delay to avoid high CPU usage
    socket.sleep(0.1)
end

