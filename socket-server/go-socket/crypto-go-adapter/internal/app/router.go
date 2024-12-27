package app

import (
	"crypto-adapter-go/internal/handlers"
	"github.com/gorilla/mux"
)

// SetupRouter - настройка маршрутов
func SetupRouter(messageChan chan string) *mux.Router {
	router := mux.NewRouter()

	router.HandleFunc("/health", handlers.HealthHandler).Methods("GET")

	// Отправка сообщения в канал
	router.HandleFunc("/transaction/status", handlers.MessageHandler(messageChan)).Methods("POST")

	return router
}
