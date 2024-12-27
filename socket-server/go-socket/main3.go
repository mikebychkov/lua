package main

import (
	"fmt"
	"net"
	"os"
	"syscall"
	"time"
)

func setQuickAck(conn *net.TCPConn) error {
	// Get the file descriptor for the TCP connection
	rawConn, err := conn.SyscallConn()
	if err != nil {
		return fmt.Errorf("failed to get raw connection: %v", err)
	}

	// Use syscall to set TCP_QUICKACK option
	var sysErr error
	err = rawConn.Control(func(fd uintptr) {
		if err := syscall.SetsockoptInt(int(fd), syscall.IPPROTO_TCP, syscall.TCP_QUICKACK, 0); err != nil {
			sysErr = fmt.Errorf("failed to set TCP_QUICKACK: %v", err)
		}
	})

	if err != nil {
		return fmt.Errorf("control failed: %v", err)
	}
	if sysErr != nil {
		return sysErr
	}
	fmt.Println("Successfully disabled TCP_QUICKACK")
	return nil
}

func handleClient(conn *net.TCPConn) {
	defer conn.Close()
	fmt.Println("New client connected")

	// Set TCP_QUICKACK for client connection
	if err := setQuickAck(conn); err != nil {
		fmt.Printf("Error setting TCP_QUICKACK for client: %v\n", err)
	}

	buffer := make([]byte, 1024) // Buffer for reading client data
	for {
		// Extend read deadline on every read attempt to keep connection alive
		err := conn.SetReadDeadline(time.Now().Add(30 * time.Second)) // Adjust to 30 seconds
		if err != nil {
			fmt.Printf("SetReadDeadline error: %v\n", err)
			break
		}

		n, err := conn.Read(buffer)
		if err != nil {
			if os.IsTimeout(err) {
				fmt.Println("Client timeout (no data for 30 seconds)")
			} else if err.Error() == "EOF" {
				fmt.Println("Client closed the connection")
			} else {
				fmt.Printf("Receive error: %v\n", err)
			}
			break
		}

		if n > 0 {
			data := string(buffer[:n])
			fmt.Printf("Received from client: %s\n", data)

			// Echo the message back to the client
			_, err = conn.Write([]byte("Echo: " + data + "\n"))
			if err != nil {
				fmt.Printf("Send error (client may have closed connection): %v\n", err)
				break
			}
		}
	}

	fmt.Println("Client connection closed.")
}

func main() {
	// Create a TCP address on all network interfaces, port 8080
	addr, err := net.ResolveTCPAddr("tcp", ":8080")
	if err != nil {
		fmt.Printf("Failed to resolve address: %v\n", err)
		return
	}

	// Listen for incoming TCP connections
	listener, err := net.ListenTCP("tcp", addr)
	if err != nil {
		fmt.Printf("Failed to start server: %v\n", err)
		return
	}
	defer listener.Close()

	// Get the file descriptor for the server socket
	rawConn, err := listener.SyscallConn()
	if err != nil {
		fmt.Printf("Failed to get raw connection: %v\n", err)
		return
	}

	var sysErr error
	err = rawConn.Control(func(fd uintptr) {
		if err := syscall.SetsockoptInt(int(fd), syscall.IPPROTO_TCP, syscall.TCP_QUICKACK, 0); err != nil {
			sysErr = fmt.Errorf("failed to set TCP_QUICKACK: %v", err)
		}
	})
	if err != nil {
		fmt.Printf("Control failed: %v\n", err)
		return
	}
	if sysErr != nil {
		fmt.Printf("Error setting TCP_QUICKACK on server socket: %v\n", sysErr)
		return
	}

	fmt.Println("Server started on Port 8080")
	for {
		// Accept incoming connections
		conn, err := listener.AcceptTCP()
		if err != nil {
			fmt.Printf("Accept error: %v\n", err)
			continue
		}

		// Handle the client in a new goroutine
		go handleClient(conn)
	}
}
