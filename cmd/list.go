package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var listCmd = &cobra.Command{
	Use:   "list [scenario|all|aws]",
	Short: "List available scenarios or AWS resources",
	Long:  `List available CTF scenarios found in the ./awsctf directory, or list deployed AWS resources.`,
	Run: func(cmd *cobra.Command, args []string) {
		target := "all"
		if len(args) > 0 {
			target = args[0]
		}

		if target == "aws" {
			fmt.Println("Listing AWS resources functionality is not yet implemented.")
			return
		}

		// List scenarios
		fmt.Println("Available Scenarios:")
		// Check if awsctf directory exists
		if _, err := os.Stat("awsctf"); os.IsNotExist(err) {
			fmt.Println("Error: 'awsctf' directory not found. Please run this command from the project root.")
			return
		}

		entries, err := os.ReadDir("awsctf")
		if err != nil {
			fmt.Printf("Error reading awsctf directory: %v\n", err)
			return
		}

		for _, entry := range entries {
			if entry.IsDir() {
				fmt.Printf("  - %s\n", entry.Name())
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(listCmd)
}
