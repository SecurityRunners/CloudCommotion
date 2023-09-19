package cmd

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/SecurityRunners/CloudCommotion/pkg/config"
	"github.com/SecurityRunners/CloudCommotion/pkg/templates"
	"github.com/SecurityRunners/CloudCommotion/pkg/terraform"
	"github.com/common-nighthawk/go-figure"
	"github.com/spf13/cobra"
)

// ASCII Banner
var appName = "Cloud Commotion"
var appVersion = "v0.0.1"
var banner = figure.NewFigure("Cloud Commotion", "larry3d", true).String()
var asciiBanner = fmt.Sprintf("%s\nby Security Runners %s\n", banner, appVersion)

// Global flags
var terraform_dir string
var terraform_loc string
var resource_name string
var sensitive_content string
var config_file string
var region string
var debug bool

var rootCmd = &cobra.Command{
	Use:     "cloudcommotion",
	Short:   "A CLI tool for causing commotion within your cloud environment",
	Long:    "Cloud Commotion purposefully creates resources that should set off alarm bells within your environment to help you prepare for an incident.",
	Example: `cloudcommotion -h`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(asciiBanner)
		cmd.Help()
	},
}

var planCmd = &cobra.Command{
	Use:   "plan",
	Short: "Plan infrastructure to be created through Cloud Commotion.",
	Long:  "Run a terraform plan on infrastructure to be created through cloud commotion",
	Run: func(cmd *cobra.Command, args []string) {
		// Welcome banner
		fmt.Println(asciiBanner)
		log.Println("Starting commotion planning, prepare for the inveitable!")

		// Check if terraform module directory exists
		// If not, download the templates
		terraform_dir := filepath.Join(os.Getenv("HOME"), ".commotion", "terraform")
		if _, err := os.Stat(terraform_dir); os.IsNotExist(err) {
			// Define repoURL if not set
			var repoURL string
			// Download the terraform templates
			err := templates.DownloadTerraformTemplates(repoURL, debug)
			if err != nil {
				log.Fatal(err)
			}
		}

		var tfdir string
		for _, mod := range config.GetConfig(config_file).Module {
			// Get the tf module directory
			if mod.TerraformLoc != "" {
				if mod.TerraformLoc == "local" {
					tfdir = mod.TerraformDir
				} else {
					// Default to remote if not set
					tfdir = filepath.Join(os.Getenv("HOME"), ".commotion", mod.TerraformDir)
				}
			}

			// Merge config.variables with module.variables
			tfvars := config.MergeVariables(config.GetConfig(config_file).Variables, mod.Variables)

			// If region flag is set, use that region
			if region != "" {
				tfvars["region"] = region
			} else {
				tfvars["region"] = config.GetConfig(config_file).Region
			}

			// If debug flag in args is set, print the terraform variables
			if debug {
				log.Println("Terraform variables: " + fmt.Sprintf("%v", tfvars))
			}

			// Plan the infrastructure to be created
			log.Println("Planning commotion infrastructure for: " + mod.Name)
			plan := terraform.PlanTerraform(tfvars, tfdir, debug)

			// Log out the results
			if plan {
				log.Println("Commotion infrastructure has been planned successfully: " + mod.Name)
			} else {
				log.Println("No changes detected for: " + mod.Name)
			}
		}

		log.Println("Completed! Now lets see how good your monitoring systems are...")
	},
}

var applyCmd = &cobra.Command{
	Use:   "apply",
	Short: "Executes individual modules",
	Long:  "Execute commotion modules located within the terraform directory",
	Run: func(cmd *cobra.Command, args []string) {
		// Welcome banner for the application
		fmt.Println(asciiBanner)
		log.Println("Starting commotion engagement, buckle your seatbelt!")

		// Check if terraform module directory exists
		// If not, download the templates
		terraform_dir := filepath.Join(os.Getenv("HOME"), ".commotion", "terraform")
		if _, err := os.Stat(terraform_dir); os.IsNotExist(err) {
			// Define repoURL if not set
			var repoURL string
			// Download the terraform templates
			err := templates.DownloadTerraformTemplates(repoURL, debug)
			if err != nil {
				log.Fatal(err)
			}
		}

		var tfdir string
		for _, mod := range config.GetConfig(config_file).Module {
			// Get the tf module directory
			if mod.TerraformLoc != "" {
				if mod.TerraformLoc == "local" {
					tfdir = mod.TerraformDir
				} else {
					// Default to remote if not set
					tfdir = filepath.Join(os.Getenv("HOME"), ".commotion", mod.TerraformDir)
				}
			}

			// Merge config.variables with module.variables
			tfvars := config.MergeVariables(config.GetConfig(config_file).Variables, mod.Variables)

			// If region flag is set, use that region
			if region != "" {
				tfvars["region"] = region
			} else {
				tfvars["region"] = config.GetConfig(config_file).Region
			}

			// If debug flag in args is set, print the terraform variables
			if debug {
				log.Println("Terraform variables: " + fmt.Sprintf("%v", tfvars))
			}

			// Plan the infrastructure to be created
			log.Println("Planning and applying commotion infrastructure for: " + mod.Name)
			plan := terraform.PlanTerraform(tfvars, tfdir, debug)

			// Apply only if plan detects changes to be made
			if plan {
				terraform.ApplyTerraform(tfvars, tfdir, debug)
			}

			// Retrieve the commotion asset
			output := terraform.OutputTerraform(tfdir)

			// Extract the exposed_asset output variable
			exposed_asset := output["exposed_asset"].Value
			raw := json.RawMessage(exposed_asset)
			asset, err := json.Marshal(&raw)
			if err != nil {
				panic(err)
			}

			// Success
			log.Println("Commotion infrastructure has been applied/updated successfully: " + string(asset))
		}

		log.Println("Completed! Now lets see how good your monitoring systems are...")
	},
}

var updateCmd = &cobra.Command{
	Use:  "update",
	Long: "Update the terraform templates",
	Run: func(cmd *cobra.Command, args []string) {
		// Print banner
		fmt.Println(asciiBanner)

		// Update the terraform templates
		var repoURL string
		err := templates.UpdateTerraformTemplates(repoURL, debug)
		if err != nil {
			log.Fatal(err)
		}
	},
}

var destroyCmd = &cobra.Command{
	Use:   "destroy",
	Short: "Destroy infrastructure created through Cloud Commotion.",
	Long:  "Run a terraform destroy on infrastructure created through cloud commotion",
	Run: func(cmd *cobra.Command, args []string) {
		// Print banner
		fmt.Println(asciiBanner)

		// Loop through modules and destroy terraform module
		var tfdir string
		for _, mod := range config.GetConfig(config_file).Module {
			// Get the tf module directory
			if mod.TerraformLoc != "" {
				if mod.TerraformLoc == "local" {
					tfdir = mod.TerraformDir
				} else {
					// Default to remote if not set
					tfdir = filepath.Join(os.Getenv("HOME"), ".commotion", mod.TerraformDir)
				}
			}

			// Merge variables
			tfvars := config.MergeVariables(config.GetConfig(config_file).Variables, mod.Variables)

			// If region flag is set, use that region
			if region != "" {
				tfvars["region"] = region
			} else {
				tfvars["region"] = config.GetConfig(config_file).Region
			}

			// If debug flag in args is set, print the terraform variables
			if debug {
				log.Println("Terraform variables: " + fmt.Sprintf("%v", tfvars))
			}

			// Destroy the infrastructure
			log.Println("Destroying commotion infrastructure for: " + mod.Name)
			terraform.DestroyTerraform(tfvars, tfdir, debug)
		}
	},
}

// Functino to retrieve the configuration from pkg/config/config.go
func GetConfig() config.Config {
	// Retrieve configuration from ~/.commotion/config and create if does not exist
	configStruct := config.GetConfig(config_file)
	return *configStruct
}

func init() {
	// Region flag
	rootCmd.PersistentFlags().StringVarP(&region, "region", "r", "", "AWS region to deploy resources")
	if region == "" {
		region, ok := os.LookupEnv("AWS_REGION")
		if !ok {
			rootCmd.MarkFlagRequired("region")
		} else {
			rootCmd.Flags().Set("region", region)
		}
	}

	// Based on the value of provider(aws, azure, gcp) if the region is set to random, then set the region to a random region
	if region == "random" {
		// Use config.GetRandomRegion() to get a random region and process error
		randregion, err := config.GetRandomRegion(config.GetConfig(config_file).Provider)
		if err != nil {
			log.Fatal(err)
		}
		region = randregion
	}

	// Global variables
	rootCmd.PersistentFlags().BoolVarP(&debug, "debug", "d", false, "enable debug mode")
	rootCmd.PersistentFlags().StringVarP(&config_file, "config", "c", "", "the config file to use")
	rootCmd.PersistentFlags().StringVarP(&sensitive_content, "flag", "f", "", "the flag to be discovered by the incident responder")
	rootCmd.PersistentFlags().StringVarP(&resource_name, "resource_name", "a", "", "the name of the resource")
	rootCmd.PersistentFlags().StringVarP(&terraform_loc, "terraform_loc", "l", "", "the location of the terraform binary")
	rootCmd.Flags().StringVarP(&terraform_dir, "terraform_dir", "t", "", "the scenario in which to run")

	// Variables for create cmd
	// applyCmd.Flags().StringVarP(&resource_name, "resource_name", "a", "", "the name of the resource")
	// applyCmd.Flags().StringVarP(&sensitive_content, "sensitive_content", "c", "", "the flag to be discovered by the incident responder")
	// applyCmd.Flags().StringVarP(&terraform_dir, "terraform_dir", "t", "", "the scenario in which to create")
}

// Execute executes the root command.
func Execute() error {
	rootCmd.CompletionOptions.DisableDefaultCmd = true
	rootCmd.SetHelpCommand(&cobra.Command{
		Use:    "no-help",
		Hidden: true,
	})

	rootCmd.HasHelpSubCommands()
	rootCmd.AddCommand(applyCmd)
	rootCmd.AddCommand(destroyCmd)
	rootCmd.AddCommand(planCmd)
	rootCmd.AddCommand(updateCmd)

	return rootCmd.Execute()
}
