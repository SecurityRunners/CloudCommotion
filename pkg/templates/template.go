package templates

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Download Terraform templates from a remote GitHub repository in to commotion root.
func DownloadTerraformTemplates(targetDir string, repoURL string, debug bool) error {
	// Check if the target directory already exists; if not, create it
	if _, err := os.Stat(targetDir); os.IsNotExist(err) {
		err := os.MkdirAll(targetDir, 0755)
		if err != nil {
			return fmt.Errorf("failed to create target directory: %v", err)
		}
	}

	// Clone the GitHub repository to the target directory
	cmd := exec.Command("git", "clone", repoURL, targetDir)
	if debug {
		log.Println("Running command: " + fmt.Sprintf("%v", cmd.Args))
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to clone repository: %v", err)
	}

	// Cleanup
	CleanupTerraformTemplatesDirectory(targetDir, debug)

	// Notification
	log.Println("Terraform modules have been downloaded.")

	return nil
}

// Run git pull within commotion root to download new Terraform templates.
//
// This function will implicitly run DownloadTerraformTemplates() if the
// commotion root directory does not exist.
func UpdateTerraformTemplates(targetDir string, repoURL string, debug bool) error {
	// Check if the target directory exists
	if _, err := os.Stat(targetDir); os.IsNotExist(err) {
		DownloadTerraformTemplates(targetDir, repoURL, debug)

		return nil
	}

	// Change directory to the target directory
	if err := os.Chdir(targetDir); err != nil {
		return fmt.Errorf("failed to change directory: %v", err)
	}

	// Pull the latest changes from the Git repository
	cmd := exec.Command("git", "pull")

	// Debug logging
	if debug {
		log.Printf("Running command %s in %s.\n", strings.Join(cmd.Args, " "), targetDir)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to update repository: %v", err)
	}

	// Cleanup
	CleanupTerraformTemplatesDirectory(targetDir, debug)

	log.Println("Terraform templates have been updated.")
	return nil
}

// CleanupTerraformTemplatesDirectory removes all files and directories except "terraform" in the target directory.
// It moves the config.yml file from config/ to the target directory.
func CleanupTerraformTemplatesDirectory(targetDir string, debug bool) error {
	// List all files and directories in the target directory
	entries, err := os.ReadDir(targetDir)
	if err != nil {
		return fmt.Errorf("failed to read directory: %v", err)
	}

	// Initialize a flag to track if config.yml was moved
	configMoved := false

	// Remove all files and directories except "terraform"
	for _, entry := range entries {
		if entry.Name() != "terraform" {
			// Preserve the config file
			if entry.Name() == "config" || entry.Name() == "config.yml" {
				configSourcePath := filepath.Join(targetDir, "config", "config.yml")
				configDestPath := filepath.Join(targetDir, "config.yml")

				if entry.Name() == "config" {
					if err := os.Rename(configSourcePath, configDestPath); err != nil {
						log.Printf("failed to move config.yml: %v", err)
					} else {
						if debug {
							log.Println("config.yml has been moved to the target directory.")
						}
					}

					// remove the config directory
					err := os.RemoveAll(filepath.Join(targetDir, "config"))
					if err != nil {
						log.Printf("failed to remove directory %s: %v", filepath.Join(targetDir, "config"), err)
					}
				}

				continue
			}

			// Preserve the .git directory
			if entry.Name() == ".git" {
				continue
			}

			entryPath := filepath.Join(targetDir, entry.Name())
			if entry.IsDir() {
				err := os.RemoveAll(entryPath)
				if debug {
					log.Println("Removing directory: " + entryPath)
				}
				if err != nil {
					log.Printf("failed to remove directory %s: %v", entryPath, err)
				}
			} else {
				err := os.Remove(entryPath)
				if debug {
					log.Println("Removing file: " + entryPath)
				}
				if err != nil {
					log.Printf("failed to remove file %s: %v", entryPath, err)
				}
			}
		}
	}

	// Move config.yml from config/ to the target directory
	configSourcePath := filepath.Join(targetDir, "config", "config.yml")
	configDestPath := filepath.Join(targetDir, "config.yml")

	if _, err := os.Stat(configSourcePath); err == nil {
		if err := os.Rename(configSourcePath, configDestPath); err != nil {
			log.Printf("failed to move config.yml: %v", err)
		} else {
			configMoved = true
		}
	}

	if configMoved {
		if debug {
			log.Println("config.yml has been moved to the target directory.")
		}
	}

	return nil
}
