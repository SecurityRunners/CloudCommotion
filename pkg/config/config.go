package config

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"

	yaml "gopkg.in/yaml.v2"
)

type Config struct {
	Provider  string                 `yaml:"provider"`
	Region    string                 `yaml:"region"`
	Module    []Module               `yaml:"module"`
	Variables map[string]interface{} `yaml:"variables"`
}

type Module struct {
	Name         string                 `yaml:"name"`
	TerraformDir string                 `yaml:"terraform_dir"`
	Variables    map[string]interface{} `yaml:"variables"`
}

func GetConfig(configfile string) *Config {
	var configFilePath string

	// Check if configfile is set
	if configfile != "" {
		// Use the provided config file path
		configFilePath = configfile
	} else {
		// If configfile is not provided, use the default path in the user's home directory
		home, err := os.UserHomeDir()
		if err != nil {
			log.Fatal(err)
		}
		configFilePath = filepath.Join(home, ".commotion", "config.yml")
	}

	// Check if the config file exists
	if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
		// If the config file and folder does not exist, create it
		err := os.MkdirAll(filepath.Dir(configFilePath), 0755)
		if err != nil {
			log.Fatal(err)
		}
		// Copy default config file
		defaultConfigFilePath := filepath.Join("config", "config.yml") // Adjust this path as per your requirements
		defaultConfig, err := os.ReadFile(defaultConfigFilePath)
		if err != nil {
			log.Fatal(err)
		}
		err = os.WriteFile(configFilePath, defaultConfig, 0644)
		if err != nil {
			log.Fatal(err)
		}
	}

	file, err := os.ReadFile(configFilePath)
	if err != nil {
		log.Fatalf("Failed to read config file: %s", err)
	}

	var config Config
	err = yaml.Unmarshal(file, &config)
	if err != nil {
		log.Fatalf("Failed to unmarshal config: %s", err)
	}

	return &config
}

func MergeVariables(globalVars map[string]interface{}, moduleVars map[string]interface{}) map[string]string {
	merged := make(map[string]string)

	// Start with global variables
	for key, value := range globalVars {
		if key != "tags" {
			merged[key] = fmt.Sprintf("%v", value) // Convert to string
		}
	}

	// Override with module specific variables
	for key, value := range moduleVars {
		if key != "tags" {
			merged[key] = fmt.Sprintf("%v", value) // Convert to string
		}
	}

	// Handle tags
	globalTags, hasGlobalTags := globalVars["tags"].(map[interface{}]interface{})
	moduleTags, hasModuleTags := moduleVars["tags"].(map[interface{}]interface{})

	if hasGlobalTags || hasModuleTags {
		mergedTags := make(map[string]string)

		// Start with global tags
		for tagKey, tagValue := range globalTags {
			mergedTags[tagKey.(string)] = fmt.Sprintf("%v", tagValue)
		}

		// Override with module tags
		for tagKey, tagValue := range moduleTags {
			mergedTags[tagKey.(string)] = fmt.Sprintf("%v", tagValue)
		}

		// Convert the merged tags to JSON string and assign to "tags" key in merged map
		tagsJSON, _ := json.Marshal(mergedTags)
		merged["tags"] = string(tagsJSON)
	}

	return merged
}
