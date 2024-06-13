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

type RuntimeFlags struct {
	// Path of the scenario to run.
	terraformDir string
	// (unused) The location of the Terraform binary.
	terraformLoc string
	// (unused) The name of the resource.
	resourceName string
	// (unused) Flag to be discovered by the incident responder.
	sensitiveContent string
	// Path to the configuration file to use.
	configFile string
	// Region to manage cloud resources in.
	region string
	// Whether or not to print debugging information for CloudCommotion.
	debug bool
	// Git URL to clone Terraform templates from.
	repoURL string

	// This is technically not a flag, but we want to reduce the number
	// of globals we have.
	config *config.Config
}

// Checks if the set RuntimeFlags.terraformDir directory exists, returns true if it does
// and false if it does not.
func (r *RuntimeFlags) terraformDirExists() bool {
	if _, err := os.Stat(r.terraformDir); os.IsNotExist(err) {
		return false
	} else {
		return true
	}
}

var runtimeFlags = RuntimeFlags{}

// Retrieve a configuration instance from pkg/config/config.go
//
// Everything that needs a reference to the config should prefer this
// function instead of config.GetConfig as this function caches the
// config instance to avoid re-reading and parsing the files after
// each call.
func GetConfig() config.Config {
	if (runtimeFlags.config != nil) {
		return *runtimeFlags.config
	}

	// Retrieve configuration from ~/.commotion/config and create if does not exist
	runtimeFlags.config = config.GetConfig(runtimeFlags.configFile)
	return *runtimeFlags.config
}

// Prints a fancy banner to standard out.
func printAsciiBanner() {
	var appName = "Cloud Commotion"
	var appVersion = "v0.0.2"
	var fontName = "larry3d"
	var banner = figure.NewFigure(appName, fontName, true).String()
	var asciiBanner = fmt.Sprintf("%s\nby Security Runners %s\n", banner, appVersion)

	fmt.Println(asciiBanner)
}

// Get the absolute path to the root commotion directory.
func getCommotionDirectory() string {
	return filepath.Join(os.Getenv("HOME"), ".commotion")
}

// Returns the absolute path to ``name`` relative to the default commotion
// install directory.
func getRelativeToCommotionDirectory(name string) string {
	return filepath.Join(os.Getenv("HOME"), ".commotion", name)
}

// The implementation for ./CloudCommotion
func rootCmdRun(cmd *cobra.Command, args []string) {
	printAsciiBanner()

	cmd.Help()
}

var rootCmd = &cobra.Command{
	Use:     "cloudcommotion",
	Short:   "A CLI tool for causing commotion within your cloud environment",
	Long:    "Cloud Commotion purposefully creates resources that should set off alarm bells within your environment to help you prepare for an incident.",
	Example: `cloudcommotion -h`,
	Run: rootCmdRun,
}

// The implementation for ./CloudCommotion plan
func planCmdRun(cmd *cobra.Command, args []string) {
	printAsciiBanner()

	log.Println("Starting commotion planning, prepare for the inevitable!")

	// Download Terraform templates if the directory does not exist
	if ! runtimeFlags.terraformDirExists() {
		commotionRoot := getCommotionDirectory()

		err := templates.DownloadTerraformTemplates(commotionRoot, runtimeFlags.repoURL, runtimeFlags.debug)
		if err != nil {
			log.Fatal(err)
		}
	}

	var tfdir string
	for _, mod := range GetConfig().Module {
		// Get the tf module directory
		if mod.TerraformLoc == "local" {
			tfdir = mod.TerraformDir
		} else {
			// Default to remote if not set
			tfdir = getRelativeToCommotionDirectory(mod.TerraformDir)
		}

		// Merge config.variables with module.variables
		tfvars := config.MergeVariables(GetConfig().Variables, mod.Variables)

		// If region flag is set, use that region
		if runtimeFlags.region != "" {
			tfvars["region"] = runtimeFlags.region
		} else {
			tfvars["region"] = GetConfig().Region
		}

		// If debug flag in args is set, print the Terraform variables
		if runtimeFlags.debug {
			log.Printf("Terraform variables: %v\n", tfvars)
			log.Printf("Terraform directory: %s\n", tfdir)
		}

		// Plan the infrastructure to be created
		log.Println("Planning commotion infrastructure for: " + mod.Name)
		plan := terraform.PlanTerraform(tfvars, tfdir, runtimeFlags.debug)

		// Log out the results
		if plan {
			log.Println("Commotion infrastructure has been planned successfully: " + mod.Name)
		} else {
			log.Println("No changes detected for: " + mod.Name)
		}
	}

	log.Println("Completed! Now lets see how good your monitoring systems are...")
}

var planCmd = &cobra.Command{
	Use:   "plan",
	Short: "Plan infrastructure to be created through Cloud Commotion.",
	Long:  "Run a Terraform plan on infrastructure to be created through cloud commotion",
	Run: planCmdRun,
}

// The implementation for ./CloudCommotion apply
func applyCmdRun(cmd *cobra.Command, args []string) {
	printAsciiBanner()

	log.Println("Starting commotion engagement, buckle your seatbelt!")

	// Download Terraform templates if we haven't already
	if ! runtimeFlags.terraformDirExists() {
		commotionRoot := getCommotionDirectory()

		err := templates.DownloadTerraformTemplates(commotionRoot, runtimeFlags.repoURL, runtimeFlags.debug)
		if err != nil {
			log.Fatal(err)
		}
	}

	var tfdir string
	for _, mod := range GetConfig().Module {
		// Get the tf module directory
		if mod.TerraformLoc == "local" {
			tfdir = mod.TerraformDir
		} else {
			// Default to remote if not set
			tfdir = getRelativeToCommotionDirectory(mod.TerraformDir)
		}

		// Merge config.variables with module.variables
		tfvars := config.MergeVariables(GetConfig().Variables, mod.Variables)

		// If region flag is set, use that region
		if runtimeFlags.region != "" {
			tfvars["region"] = runtimeFlags.region
		} else {
			tfvars["region"] = GetConfig().Region
		}

		// If debug flag in args is set, print the Terraform variables
		if runtimeFlags.debug {
			log.Printf("Terraform variables: %v\n", tfvars)
			log.Println("Terraform directory: " + tfdir)
			log.Println("Terraform mod:" + mod.TerraformDir)
		}

		// Plan the infrastructure to be created
		log.Println("Planning and applying commotion infrastructure for: " + mod.Name)
		plan := terraform.PlanTerraform(tfvars, tfdir, runtimeFlags.debug)

		// Apply only if plan detects changes to be made
		if plan {
			terraform.ApplyTerraform(tfvars, tfdir, runtimeFlags.debug)
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
}

var applyCmd = &cobra.Command{
	Use:   "apply",
	Short: "Executes individual modules",
	Long:  "Execute commotion modules located within the terraform directory",
	Run: applyCmdRun,
}

// The implementation for ./CloudCommotion update
func updateCmdRun(cmd *cobra.Command, args []string) {
	printAsciiBanner()

	// Update the Terraform templates
	commotionRoot := getCommotionDirectory()

	err := templates.UpdateTerraformTemplates(commotionRoot, runtimeFlags.repoURL, runtimeFlags.debug)
	if err != nil {
		log.Fatal(err)
	}
}

var updateCmd = &cobra.Command{
	Use:  "update",
	Short: "Update the Terraform templates",
	Long: "Update the Terraform templates",
	Run: updateCmdRun,
}

// The implementation for ./CloudCommotion destroy
func destroyCmdRun(cmd *cobra.Command, args []string) {
	printAsciiBanner()

	// Loop through modules and destroy Terraform module
	var tfdir string
	for _, mod := range GetConfig().Module {
		// Get the tf module directory
		if mod.TerraformLoc == "local" {
			tfdir = mod.TerraformDir
		} else {
			// Default to remote if not set
			tfdir = getRelativeToCommotionDirectory(mod.TerraformDir)
		}

		// Merge variables
		tfvars := config.MergeVariables(GetConfig().Variables, mod.Variables)

		// If region flag is set, use that region
		if runtimeFlags.region != "" {
			tfvars["region"] = runtimeFlags.region
		} else {
			tfvars["region"] = GetConfig().Region
		}

		// If debug flag in args is set, print the Terraform variables
		if runtimeFlags.debug {
			log.Printf("Terraform variables: %v\n", tfvars)
			log.Println("Terraform directory: " + tfdir)
		}

		// Destroy the infrastructure
		log.Println("Destroying commotion infrastructure for: " + mod.Name)
		terraform.DestroyTerraform(tfvars, tfdir, runtimeFlags.debug)
	}
}

var destroyCmd = &cobra.Command{
	Use:   "destroy",
	Short: "Destroy infrastructure created through Cloud Commotion.",
	Long:  "Run a terraform destroy on infrastructure created through cloud commotion",
	Run: destroyCmdRun,
}

// This defines the CLI argument flags that are passed to our global runtime cache.
func init() {
	rootCmd.PersistentFlags().StringVarP(&runtimeFlags.region, "region", "r", "", "AWS region to deploy resources")
	if runtimeFlags.region == "" {
		region, ok := os.LookupEnv("AWS_REGION")
		runtimeFlags.region = region
		if ok {
			rootCmd.Flags().Set("region", runtimeFlags.region)
		} else {
			rootCmd.MarkFlagRequired("region")
		}
	}

	if runtimeFlags.region == "random" {
		// Generate a random region based on the cloud provider specified in the config file
		randregion, err := config.GetRandomRegion(GetConfig().Provider)
		if err != nil {
			log.Fatal(err)
		}
		runtimeFlags.region = randregion
	}

	rootCmd.PersistentFlags().BoolVarP(&runtimeFlags.debug, "debug", "d", false, "enable debug mode")
	rootCmd.PersistentFlags().StringVarP(&runtimeFlags.configFile, "config", "c", "", "the config file to use")
	rootCmd.PersistentFlags().StringVarP(&runtimeFlags.sensitiveContent, "flag", "f", "", "the flag to be discovered by the incident responder")
	rootCmd.PersistentFlags().StringVarP(&runtimeFlags.resourceName, "resource_name", "a", "", "the name of the resource")
	rootCmd.PersistentFlags().StringVarP(&runtimeFlags.terraformLoc, "terraform_loc", "l", "", "the location of the terraform binary")
	rootCmd.Flags().StringVarP(&runtimeFlags.terraformDir, "terraform_dir", "t", "", "the scenario in which to run")

	// Always ensure a terraform directory is set
	if runtimeFlags.terraformDir == "" {
		runtimeFlags.terraformDir = getRelativeToCommotionDirectory("terraform")
	}

	var defaultGitUrl = "git@github.com:SecurityRunners/CloudCommotion.git"

	rootCmd.PersistentFlags().StringVarP(&runtimeFlags.repoURL, "repo_url", "u", defaultGitUrl, "git repository to download Terraform templates from")

	// Always ensure a repository URL is set
	if runtimeFlags.repoURL == "" {
		runtimeFlags.repoURL = defaultGitUrl
	}
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
