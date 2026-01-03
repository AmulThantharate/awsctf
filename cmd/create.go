package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/spf13/cobra"
)

var createCmd = &cobra.Command{
	Use:   "create [scenario]",
	Short: "Deploy a CTF scenario",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		scenario := args[0]
		scenarioPath := filepath.Join("awsctf", scenario)

		if _, err := os.Stat(scenarioPath); os.IsNotExist(err) {
			fmt.Printf("Error: Scenario '%s' not found within 'awsctf/' directory.\n", scenario)
			return
		}

		fmt.Printf("[+] Deploying scenario: %s\n", scenario)

		// Check for deploy.sh
		deployScript := filepath.Join(scenarioPath, "deploy.sh")
		if _, err := os.Stat(deployScript); err == nil {
			fmt.Println("[*] Found deploy.sh, executing...")
			// We execute from the scenario directory so relative paths in script work
			runCommand("/bin/bash", []string{deployScript}, scenarioPath)
			return
		}

		// Check for terraform directory
		terraformDir := filepath.Join(scenarioPath, "terraform")
		if _, err := os.Stat(terraformDir); err == nil {
			deployTerraform(terraformDir)
			return
		}

		fmt.Println("Error: No valid deployment method found (deploy.sh or terraform/ directory).")
	},
}

func runCommand(name string, args []string, dir string) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Env = os.Environ() // Inherit environment including .env loaded by godotenv

	if err := cmd.Run(); err != nil {
		fmt.Printf("Error executing command: %v\n", err)
	}
}

func deployTerraform(dir string) {
	fmt.Println("[*] Initializing Terraform...")
	runCommand("terraform", []string{"init"}, dir)

	fmt.Println("[*] Applying Terraform...")
	runCommand("terraform", []string{"apply", "-auto-approve"}, dir)
}

func init() {
	rootCmd.AddCommand(createCmd)
}
