package config

import (
	"log"

	"github.com/spf13/viper"
)

var AppConfig *viper.Viper

func InitConfig() {
	AppConfig = viper.New()
	AppConfig.SetConfigName("config") // Имя файла конфигурации (без расширения)
	AppConfig.SetConfigType("yaml")   // Тип файла конфигурации
	AppConfig.AddConfigPath(".")      // Путь к файлу конфигурации (текущая директория)

	err := AppConfig.ReadInConfig()
	if err != nil {
		log.Fatalf("Error reading config file: %v", err)
	}
}
