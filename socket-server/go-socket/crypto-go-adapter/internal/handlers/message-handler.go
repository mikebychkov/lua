package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
)

// RequestPayload - структура для JSON-запроса
type RequestPayload struct {
	StatusMessage string `json:"statusMessage"`
}

var (
	socketConnected bool
	socketMutex     sync.Mutex
)

// SetSocketConnected - устанавливает состояние сокет-клиента
func SetSocketConnected(state bool) {
	socketMutex.Lock()
	defer socketMutex.Unlock()
	socketConnected = state
}

// IsSocketConnected - возвращает состояние сокет-клиента
func IsSocketConnected() bool {
	socketMutex.Lock()
	defer socketMutex.Unlock()
	return socketConnected
}

// MessageHandler - обработчик для получения statusMessage и отправки в существующий канал
func MessageHandler(messageChan chan string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Проверяем состояние соединения с сокет-клиентом
		if !IsSocketConnected() {
			respondWithJSON(w, http.StatusServiceUnavailable, map[string]string{
				"error": "No active socket client connection!",
			})
			return
		}

		// Декодируем JSON-запрос
		var payload RequestPayload
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			respondWithJSON(w, http.StatusBadRequest, map[string]string{
				"error": "Invalid request payload!",
			})
			return
		}

		// Проверяем наличие поля
		if payload.StatusMessage == "" {
			respondWithJSON(w, http.StatusBadRequest, map[string]string{
				"error": "Missing field: statusMessage!",
			})
			return
		}

		// Логируем сообщение
		log.Printf("Received statusMessage: %s", payload.StatusMessage)

		// Отправляем сообщение в канал
		select {
		case messageChan <- payload.StatusMessage:
			log.Printf("Message sent to channel: %s", payload.StatusMessage)
		default:
			respondWithJSON(w, http.StatusServiceUnavailable, map[string]string{
				"error": "Server busy, try again later!",
			})
			return
		}

		// Отправляем успешный ответ
		respondWithJSON(w, http.StatusOK, map[string]string{
			"result": "Message sent!",
		})
	}
}

func respondWithJSON(w http.ResponseWriter, statusCode int, payload map[string]string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("Failed to send JSON response: %v", err)
	}
}
