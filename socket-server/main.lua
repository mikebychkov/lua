local socket = require("socket")  -- Import LuaSocket

-- Create a TCP socket and bind it to the local host, port 8080
local server = assert(socket.bind("*", 8080)) -- Binds to all IP addresses (*), port 8080
local ip, port = server:getsockname()

print("Server started on IP: " .. ip .. ", Port: " .. port)

-- Set the server to non-blocking mode (optional)
server:settimeout(0)

-- Table to keep track of connected clients
local clients = {}

while true do
    -- Accept new incoming connections
    local client = server:accept()
    if client then
        -- New client connected
        print("New client connected")
        -- Set the client to non-blocking mode
        client:settimeout(0)
        -- Add the client to the list of connected clients
        table.insert(clients, client)
    end
    -- Loop through all connected clients to check for incoming data
    for i, client in ipairs(clients) do
        local data, err = client:receive()
        if data then
            print("Received from client: " .. data)
            -- Echo the message back to the client
            client:send("Echo: " .. data .. "\n")
        elseif err == "closed" then
            -- Client disconnected, remove it from the client list
            print("Client disconnected")
            client:close()
            table.remove(clients, i)
        end
    end
    -- (Optional) Add a small delay to avoid high CPU usage
    socket.sleep(0.1)
end

