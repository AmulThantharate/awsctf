package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var destroyCmd = &cobra.Command{
	Use:   "destroy [scenario|all]",
	Short: "Destroy a CTF scenario or all deployed scenarios",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		target := args[0]

		if target == "all" {
			destroyAll()
			return
		}

		destroyScenario(target)
	},
}

func destroyAll() {
	fmt.Println("Destroying ALL scenarios...")
	entries, err := os.ReadDir("awsctf")
	if err != nil {
		fmt.Printf("Error reading awsctf directory: %v\n", err)
		return
	}

	for _, entry := range entries {
		if entry.IsDir() {
			destroyScenario(entry.Name())
		}
	}
}

func destroyScenario(scenario string) {
	scenarioPath := filepath.Join("awsctf", scenario)
	if _, err := os.Stat(scenarioPath); os.IsNotExist(err) {
		fmt.Printf("Error: Scenario '%s' not found.\n", scenario)
		return
	}

	fmt.Printf("[-] Destroying scenario: %s\n", scenario)

	// Check for destroy.sh
	destroyScript := filepath.Join(scenarioPath, "destroy.sh")
	if _, err := os.Stat(destroyScript); err == nil {
		fmt.Println("[*] Found destroy.sh, executing...")
		runCommand("/bin/bash", []string{destroyScript}, scenarioPath)
		return
	}

	// Check for terraform directory
	terraformDir := filepath.Join(scenarioPath, "terraform")
	if _, err := os.Stat(terraformDir); err == nil {
		destroyTerraform(terraformDir)
		return
	}

	fmt.Printf("Warning: No destroy method found for %s\n", scenario)
}

func destroyTerraform(dir string) {
	fmt.Println("[*] Running Terraform Destroy...")
	runCommand("terraform", []string{"destroy", "-auto-approve"}, dir)
}

func init() {
	rootCmd.AddCommand(destroyCmd)
}
