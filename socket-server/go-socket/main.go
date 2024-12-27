package main

/*
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/socket.h>
#include <unistd.h>

// Отключение TCP_QUICKACK
int DisableQuickAck(int sockfd) {
    int optval = 0; // 0 отключает TCP_QUICKACK
    return setsockopt(sockfd, IPPROTO_TCP, TCP_QUICKACK, &optval, sizeof(optval));
}

// Включение TCP_NODELAY
int EnableNoDelay(int sockfd) {
    int optval = 1; // 1 включает TCP_NODELAY
    return setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, &optval, sizeof(optval));
}

// Включение TCP_CORK
int EnableCork(int sockfd) {
    int optval = 1; // 1 включает TCP_CORK
    return setsockopt(sockfd, IPPROTO_TCP, TCP_CORK, &optval, sizeof(optval));
}

// Выключение TCP_CORK
int DisableCork(int sockfd) {
    int optval = 0; // 0 отключает TCP_CORK
    return setsockopt(sockfd, IPPROTO_TCP, TCP_CORK, &optval, sizeof(optval));
}
*/
import "C"
import (
  "bufio"
  "fmt"
  "log"
  "net"
  "os"
  "os/signal"
  "syscall"
  "time"
)

const (
  port = ":8082"
)

func main() {
  signalChan := make(chan os.Signal, 1)
  signal.Notify(signalChan, os.Interrupt, syscall.SIGTERM)

  listener, err := net.Listen("tcp", "0.0.0.0"+port)
  if err != nil {
    log.Fatalf("Failed to start server: %v", err)
  }
  defer listener.Close()

  log.Printf("TCP server cork started on port %s", port)

  go func() {
    for {
      conn, err := listener.Accept()
      if err != nil {
        log.Printf("Connection error: %v", err)
        continue
      }

      go handleConnection(conn)
    }
  }()

  <-signalChan
  log.Println("Shutting down server...")
}

func handleConnection(conn net.Conn) {
  defer conn.Close()

  log.Printf("Accepted new connection from %s", conn.RemoteAddr())

  tcpConn, ok := conn.(*net.TCPConn)
  if !ok {
    log.Println("Failed to assert connection as TCPConn")
    return
  }

  rawConn, err := tcpConn.SyscallConn()
  if err != nil {
    log.Printf("Error getting raw connection: %v", err)
    return
  }

  // Отключаем TCP_QUICKACK
  err = rawConn.Control(func(fd uintptr) {
    if res := C.DisableQuickAck(C.int(fd)); res != 0 {
      log.Printf("Failed to disable TCP_QUICKACK: %d", res)
    } else {
      log.Println("TCP_QUICKACK disabled for client connection")
    }
  })
  if err != nil {
    log.Printf("Error applying TCP_QUICKACK: %v", err)
    return
  }

  // Включаем TCP_CORK
  err = rawConn.Control(func(fd uintptr) {
    if res := C.EnableCork(C.int(fd)); res != 0 {
      log.Printf("Failed to enable TCP_CORK: %d", res)
    } else {
      log.Println("TCP_CORK enabled for client connection")
    }
  })
  if err != nil {
    log.Printf("Error enabling TCP_CORK: %v", err)
    return
  }

  // Читаем данные от клиента
  reader := bufio.NewReader(conn)
  request, err := reader.ReadString('\n')
  if err != nil {
    log.Printf("Error reading request: %v", err)
    return
  }

  log.Printf("Received request: %s", request)

  // Отправляем ответ клиенту
  _, err = fmt.Fprintf(conn, "Echo: %s", request)
  if err != nil {
    log.Printf("Error sending response: %v", err)
  }

  // Задержка для объединения пакетов
  time.Sleep(10 * time.Millisecond)

  // Выключаем TCP_CORK
  err = rawConn.Control(func(fd uintptr) {
    if res := C.DisableCork(C.int(fd)); res != 0 {
      log.Printf("Failed to disable TCP_CORK: %d", res)
    } else {
      log.Println("TCP_CORK disabled for client connection")
    }
  })
  if err != nil {
    log.Printf("Error disabling TCP_CORK: %v", err)
  }
}
