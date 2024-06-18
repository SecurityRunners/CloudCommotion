package config

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math/rand"
	"os"
	"path/filepath"
	"time"

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
	TerraformLoc string                 `yaml:"terraform_loc"`
	Variables    map[string]interface{} `yaml:"variables"`
}

// Get the absolute path to the root commotion directory.
func GetCommotionDirectory() string {
	return filepath.Join(os.Getenv("HOME"), ".commotion")
}

// Returns the absolute path to ``name`` relative to the default commotion
// install directory.
func GetRelativeToCommotionDirectory(name string) string {
	return filepath.Join(os.Getenv("HOME"), ".commotion", name)
}

// Get the tf module directory
func (mod Module) TfDir() string {
	if mod.TerraformLoc == "local" {
		return mod.TerraformDir
	} else {
		// Default to remote if not set
		return GetRelativeToCommotionDirectory(mod.TerraformDir)
	}
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

// Function to return random regions, hard coding regions as using the sdk may not be ideal
func GetRandomRegion(provider string) (string, error) {
	rand.Seed(time.Now().UnixNano())

	awsRegions := []string{"us-east-1", "us-west-1", "us-west-2", "eu-west-1", "eu-central-1", "ap-south-1", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2", "sa-east-1"}
	gcpRegions := []string{"us-central1", "us-west1", "us-east1", "us-east4", "northamerica-northeast1", "southamerica-east1", "europe-west1", "europe-west2", "europe-west3", "europe-west4", "europe-west6", "europe-north1", "asia-south1", "asia-southeast1", "asia-southeast2", "asia-east1", "asia-east2", "asia-northeast1", "asia-northeast2", "asia-northeast3", "australia-southeast1"}
	azureRegions := []string{"eastus", "eastus2", "southcentralus", "westus2", "westus", "westcentralus", "centralus", "northcentralus", "westeurope", "northeurope", "uksouth", "ukwest", "francecentral", "francesouth", "germanywestcentral", "germanynorth", "switzerlandnorth", "switzerlandwest", "norwayeast", "norwaywest"}

	switch provider {
	case "aws":
		return awsRegions[rand.Intn(len(awsRegions))], nil
	case "gcp":
		return gcpRegions[rand.Intn(len(gcpRegions))], nil
	case "azure":
		return azureRegions[rand.Intn(len(azureRegions))], nil
	default:
		return "", errors.New("Unknown provider")
	}
}
