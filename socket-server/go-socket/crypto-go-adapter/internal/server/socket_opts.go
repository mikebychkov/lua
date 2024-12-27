package server

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

// Включение TCP_CORK
int EnableCork(int sockfd) {
    int optval = 1; // 1 включает TCP_CORK
    return setsockopt(sockfd, IPPROTO_TCP, TCP_CORK, &optval, sizeof(optval));
}

// Уменьшение размера TCP окна
int SetReceiveWindow(int sockfd, int size) {
    return setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &size, sizeof(size));
}

int SetSocketBuffer(int sockfd, int size) {
    return setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &size, sizeof(size));
}

// Выключение TCP_CORK
int DisableCork(int sockfd) {
    int optval = 0; // 0 отключает TCP_CORK
    return setsockopt(sockfd, IPPROTO_TCP, TCP_CORK, &optval, sizeof(optval));
}
*/
import "C"
import (
	"fmt"
	"log"
	"net"
)

func (s *TcpServer) setupSocketOptions(conn net.Conn) error {
	tcpConn, ok := conn.(*net.TCPConn)
	if !ok {
		return fmt.Errorf("failed to cast to TCPConn")
	}

	rawConn, err := tcpConn.SyscallConn()
	if err != nil {
		return fmt.Errorf("failed to get raw connection: %w", err)
	}

	// Установка минимального размера сокетного буфера
	if err := rawConn.Control(func(fd uintptr) {
		if res := C.SetSocketBuffer(C.int(fd), 1024); res != 0 {
			log.Printf("Failed to set socket buffer: %v", res)
		}
	}); err != nil {
		return fmt.Errorf("failed to set socket buffer: %w", err)
	}

	// Отключение TCP_QUICKACK
	if err := rawConn.Control(func(fd uintptr) {
		if res := C.DisableQuickAck(C.int(fd)); res != 0 {
			log.Printf("Failed to disable TCP_QUICKACK: %v", res)
		}
	}); err != nil {
		return fmt.Errorf("failed to disable TCP_QUICKACK: %w", err)
	}

	return nil
}
