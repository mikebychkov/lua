package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type CryptoPayService struct {
	endpoint string
}

func NewCryptoPayService(endpoint string) *CryptoPayService {
	return &CryptoPayService{
		endpoint: endpoint,
	}
}

//func (s *CryptoPayService) SendRequest(payload string) (string, error) {
//	// Формируем JSON для отправки
//	requestBody, err := json.Marshal(map[string]string{
//		"data": payload,
//	})
//	if err != nil {
//		return "", fmt.Errorf("failed to marshal payload: %v", err)
//	}
//
//	// Логируем сформированный JSON
//	log.Printf("Mocked Request JSON: %s", string(requestBody))
//
//	// Возвращаем сгенерированный JSON вместо отправки HTTP-запроса
//	return string(requestBody), nil
//}

func (s *CryptoPayService) SendRequest(payload string) (string, error) {
	// Формируем JSON для отправки
	requestBody, err := json.Marshal(map[string]string{
		"data": payload,
	})
	if err != nil {
		return "", fmt.Errorf("failed to marshal payload: %v", err)
	}

	// Отправка POST-запроса
	resp, err := http.Post(s.endpoint, "application/json", bytes.NewBuffer(requestBody))
	if err != nil {
		return "", fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	// Чтение ответа
	responseBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("received non-OK status: %d, response: %s", resp.StatusCode, string(responseBody))
	}

	// Парсим JSON-ответ и извлекаем значение `statusMessage`
	var responseMap map[string]string
	if err := json.Unmarshal(responseBody, &responseMap); err != nil {
		return "", fmt.Errorf("failed to parse response: %v", err)
	}

	statusMessage, exists := responseMap["statusMessage"]
	if !exists {
		return "", fmt.Errorf("statusMessage not found in response: %s", string(responseBody))
	}

	return statusMessage, nil
}
