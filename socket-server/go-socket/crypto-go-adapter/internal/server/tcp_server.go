package server

/*
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/socket.h>
#include <unistd.h>

// Включение TCP_NODELAY
int EnableNoDelay(int sockfd) {
    int optval = 1; // 1 включает TCP_NODELAY
    return setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, &optval, sizeof(optval));
}
*/
import "C"
import (
	"bufio"
	"crypto-adapter-go/config"
	"crypto-adapter-go/internal/handlers"
	"crypto-adapter-go/internal/services"
	"fmt"
	"io"
	"log"
	"net"
	"strings"
	"sync"
)

type TcpServer struct {
	listener       net.Listener
	clientHandlers sync.WaitGroup
	shutdown       chan struct{}
	cryptoService  *services.CryptoPayService
	activeConns    sync.Map
}

func NewTcpServer(cryptoService *services.CryptoPayService) *TcpServer {
	return &TcpServer{
		shutdown:      make(chan struct{}),
		cryptoService: cryptoService,
	}
}

func (s *TcpServer) Start() {
	var err error
	port := config.AppConfig.GetString("server.tcp-port")
	s.listener, err = net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
	defer s.listener.Close()

	log.Printf("TCP server-8 started on port %s", port)

	for {
		select {
		case <-s.shutdown:
			log.Println("Server is shutting down...")
			return
		default:
		}

		conn, err := s.listener.Accept()
		if err != nil {
			log.Printf("Connection error: %v", err)
			continue
		}

		s.clientHandlers.Add(1)
		go s.handleConnection(conn)
	}
}

func (s *TcpServer) handleConnection(conn net.Conn) {
	clientID := conn.RemoteAddr().String() // Используем адрес как уникальный идентификатор
	defer func() {
		conn.Close()
		s.activeConns.Delete(clientID)
		s.clientHandlers.Done()
	}()

	s.activeConns.Store(clientID, conn)

	if err := s.setupSocketOptions(conn); err != nil {
		log.Printf("Failed to setup socket options: %v", err)
		return
	}

	log.Printf("Accepted new connection from %s", conn.RemoteAddr())

	defer func() {
		conn.Close()
		handlers.SetSocketConnected(false) // Устанавливаем состояние в false при разрыве соединения
	}()

	handlers.SetSocketConnected(true) // Устанавливаем состояние в true при подключении
	log.Printf("Socket client connected: %s", conn.RemoteAddr())

	s.processConnection(conn)
}

func (s *TcpServer) processConnection(conn net.Conn) {
	reader := bufio.NewReader(conn)

	for {
		select {
		case <-s.shutdown:
			log.Println("Shutting down connection handler")
			return
		default:
		}

		// Чтение данных от клиента
		request, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				log.Printf("Client %s disconnected", conn.RemoteAddr())
			} else {
				log.Printf("Error reading from client: %v", err)
			}
			return
		}

		log.Printf("Received from %s: %s", conn.RemoteAddr(), request)

		// Возврат статичного ответа клиенту перед отправкой REST-запроса
		staticResponse := "0000461804003001000200000090862720241204150404831800"
		if _, err := fmt.Fprintf(conn, "%s\n", staticResponse); err != nil {
			log.Printf("Error writing static response to client: %v", err)
			return
		}

		// Выполнение REST-запроса
		response, err := s.cryptoService.SendRequest(strings.TrimSpace(request))
		if err != nil {
			log.Printf("Error sending REST request: %v", err)
			fmt.Fprintf(conn, "Error processing request: %v\n", err)
			continue
		}

		// Отправка REST-ответа клиенту
		if _, err := fmt.Fprintf(conn, "%s\n", response); err != nil {
			log.Printf("Error writing REST response to client: %v", err)
			return
		}

		// Опционально включить TCP_QUICKACK обратно
		s.enableTcpNoDelay(conn)
	}
}

func (s *TcpServer) enableTcpNoDelay(conn net.Conn) {
	tcpConn, ok := conn.(*net.TCPConn)
	if !ok {
		log.Println("Failed to cast to TCPConn for TCP_NODELAY")
		return
	}

	rawConn, err := tcpConn.SyscallConn()
	if err != nil {
		log.Printf("Failed to get raw connection for TCP_NODELAY: %v", err)
		return
	}

	// Включение TCP_NODELAY, если нужно немедленное подтверждение
	if err := rawConn.Control(func(fd uintptr) {
		if res := C.EnableNoDelay(C.int(fd)); res != 0 {
			log.Printf("Failed to enable TCP_NODELAY: %v", res)
		}
	}); err != nil {
		log.Printf("Failed to enable TCP_NODELAY: %v", err)
	}
}

func (s *TcpServer) ListenForMessages(messageChan chan string) {
	go func() {
		for {
			select {
			case <-s.shutdown:
				log.Println("Stopping message listener")
				return
			case message := <-messageChan:
				log.Printf("Broadcasting message: %s", message)
				s.sendMessageToClients(message)
			}
		}
	}()
}

func (s *TcpServer) sendMessageToClients(message string) {
	s.activeConns.Range(func(key, value interface{}) bool {
		conn, ok := value.(net.Conn)
		if !ok {
			log.Printf("Invalid connection for client: %v", key)
			return true // Продолжаем итерацию
		}

		_, err := fmt.Fprintf(conn, "%s\n", message)
		if err != nil {
			log.Printf("Failed to send message to client %v: %v", key, err)
			s.activeConns.Delete(key) // Удаляем невалидное соединение
		} else {
			log.Printf("Message sent to client %v: %s", key, message)
		}
		return true
	})
}

func (s *TcpServer) Stop() {
	close(s.shutdown)
	s.listener.Close()
	s.clientHandlers.Wait()
	log.Println("Server has stopped.")
}
