package terraform

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/hashicorp/terraform-exec/tfexec"
)

func initializeTerraform(tfdir string) (*tfexec.Terraform, context.Context) {
	// Create new tfexec instance
	tf, err := tfexec.NewTerraform(tfdir, "terraform")
	if err != nil {
		log.Fatalf("Failed to create Terraform instance: %s", err)
	}

	// Set up the context
	ctx := context.Background()

	// Initialize Terraform
	err = tf.Init(ctx, tfexec.Upgrade(true))
	if err != nil {
		log.Fatalf("Failed to initialize Terraform: %s", err)
	}

	return tf, ctx
}

func PlanTerraform(tfvars map[string]string, tfdir string, debug bool) bool {
	// Setup terraform and context
	tf, ctx := initializeTerraform(tfdir)

	// Plan variable options
	planOpts := make([]tfexec.PlanOption, 0, len(tfvars))
	for k, v := range tfvars {
		planOpts = append(planOpts, tfexec.Var(fmt.Sprintf("%s=%s", k, v)))
	}

	// Set debug options
	if debug {
		tf.SetStdout(os.Stdout)
		tf.SetStderr(os.Stderr)
	}

	// Run Terraform plan
	plandiff, err := tf.Plan(ctx, planOpts...)
	if err != nil {
		log.Fatalf("Failed to plan Terraform: %s", err)
	}

	// The returned boolean is false when the plan diff is empty (no changes) and true when the plan diff is non-empty (changes present).
	if !plandiff {
		return false
	}

	return plandiff
}

func ApplyTerraform(tfvars map[string]string, tfdir string, debug bool) {
	// Setup terraform and context
	tf, ctx := initializeTerraform(tfdir)

	// Apply variables
	applyOpts := make([]tfexec.ApplyOption, 0, len(tfvars))
	for k, v := range tfvars {
		applyOpts = append(applyOpts, tfexec.Var(fmt.Sprintf("%s=%s", k, v)))
	}

	// Set debug options
	if debug {
		log.Println(tfvars)
		tf.SetStdout(os.Stdout)
		tf.SetStderr(os.Stderr)
	}

	// Apply the terraform
	err := tf.Apply(ctx, applyOpts...)
	if err != nil {
		log.Fatalf("Failed to apply Terraform: %s", err)
	}
}

func DestroyTerraform(tfvars map[string]string, tfdir string, debug bool) {
	// Setup terraform and context
	tf, ctx := initializeTerraform(tfdir)

	// Destroy variables
	destroyOpts := make([]tfexec.DestroyOption, 0, len(tfvars))
	for k, v := range tfvars {
		destroyOpts = append(destroyOpts, tfexec.Var(fmt.Sprintf("%s=%s", k, v)))
	}

	// Set debug options
	if debug {
		tf.SetStdout(os.Stdout)
		tf.SetStderr(os.Stderr)
	}

	// Destroy the terraform
	err := tf.Destroy(ctx, destroyOpts...)
	if err != nil {
		log.Fatalf("Failed to destroy Terraform: %s", err)
	}

	log.Println("Successfully destroyed the infrastructure")
}

func OutputTerraform(tfdir string) map[string]tfexec.OutputMeta {
	// Setup terraform and context
	tf, ctx := initializeTerraform(tfdir)

	// Retrieve and print the outputs
	output, err := tf.Output(ctx)
	if err != nil {
		log.Fatalf("Failed to retrieve terraform output: %s", err)
	}

	return output
}
