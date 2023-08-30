package cmd

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/SecurityRunners/CloudCommotion/pkg/config"
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

		var tfdir string
		for _, mod := range config.GetConfig(config_file).Module {
			// Get the tf module directory
			tfdir = mod.TerraformDir

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

var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Executes individual modules",
	Long:  "Execute commotion modules located within the terraform directory",
	Run: func(cmd *cobra.Command, args []string) {
		// Welcome banner for the application
		fmt.Println(asciiBanner)

		log.Println("Starting commotion engagement, buckle your seatbelt!")

		var tfdir string
		for _, mod := range config.GetConfig(config_file).Module {
			// Get the tf module directory
			tfdir = mod.TerraformDir

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
			// Get tf module directory
			tfdir = mod.TerraformDir

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

	// Global variables
	rootCmd.PersistentFlags().BoolVarP(&debug, "debug", "d", false, "enable debug mode")
	rootCmd.PersistentFlags().StringVarP(&config_file, "config", "c", "", "the config file to use")
	rootCmd.PersistentFlags().StringVarP(&sensitive_content, "flag", "f", "", "the flag to be discovered by the incident responder")
	rootCmd.PersistentFlags().StringVarP(&resource_name, "resource_name", "a", "", "the name of the resource")
	rootCmd.Flags().StringVarP(&terraform_dir, "terraform_dir", "t", "", "the scenario in which to run")

	// Variables for create cmd
	// createCmd.Flags().StringVarP(&resource_name, "resource_name", "a", "", "the name of the resource")
	// createCmd.Flags().StringVarP(&sensitive_content, "sensitive_content", "c", "", "the flag to be discovered by the incident responder")
	// createCmd.Flags().StringVarP(&terraform_dir, "terraform_dir", "t", "", "the scenario in which to create")
}

// Execute executes the root command.
func Execute() error {
	rootCmd.CompletionOptions.DisableDefaultCmd = true
	rootCmd.SetHelpCommand(&cobra.Command{
		Use:    "no-help",
		Hidden: true,
	})

	rootCmd.HasHelpSubCommands()
	rootCmd.AddCommand(createCmd)
	rootCmd.AddCommand(destroyCmd)
	rootCmd.AddCommand(planCmd)

	return rootCmd.Execute()
}
