package main

import (
	"crypto-adapter-go/config"
	"crypto-adapter-go/internal/app"
	"crypto-adapter-go/internal/server"
	"crypto-adapter-go/internal/services"
	"log"
	"net/http"
)

func main() {
	// Инициализация конфигурации
	config.InitConfig()

	// Получение значения из конфигурации
	endpoint := config.AppConfig.GetString("cryptopay.endpoint")
	if endpoint == "" {
		log.Fatalf("cryptopay.endpoint is not set in configuration")
	}

	// Создание сервиса
	cryptoService := services.NewCryptoPayService(endpoint)
	tcpServer := server.NewTcpServer(cryptoService)

	messageChan := make(chan string, 100) // Канал для сообщений

	// Запуск прослушивания сообщений
	tcpServer.ListenForMessages(messageChan)

	// Запуск HTTP-сервера
	go startHTTPServer(messageChan)

	// Запуск TCP-сервера
	tcpServer.Start()

	// Завершение работы сервера
	tcpServer.Stop()
}

func startHTTPServer(messageChan chan string) {
	router := app.SetupRouter(messageChan)
	port := config.AppConfig.GetString("server.http-port")
	log.Printf("HTTP server started on port %s", port)
	if err := http.ListenAndServe(port, router); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
	}
}
