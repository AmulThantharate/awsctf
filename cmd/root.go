package cmd

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "awsctf",
	Short: "A CLI for deploying and managing AWS CTF challenges",
	Long: `awsctf is a CLI tool that helps you deploy, manage, and destroy 
AWS CTF scenarios. It wraps Terraform and shell scripts to provide a 
seamless experience.`,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)
	rootCmd.SetHelpCommand(&cobra.Command{
		Use:   "help [command | scenario]",
		Short: "Help about any command or scenario",
		Run: func(c *cobra.Command, args []string) {
			if len(args) == 0 {
				rootCmd.Help()
				return
			}

			// Check if it's a known command
			cmd, _, _ := rootCmd.Find(args)
			if cmd != nil && cmd != rootCmd {
				cmd.Help()
				return
			}

			// Check if it's a scenario
			scenario := args[0]
			// We check for awsctf directory in the current working directory
			scenarioPath := fmt.Sprintf("awsctf/%s", scenario)
			if _, err := os.Stat(scenarioPath); err == nil {
				fmt.Printf("Scenario: %s\n", scenario)
				readmePath := fmt.Sprintf("%s/README.md", scenarioPath)
				if content, err := os.ReadFile(readmePath); err == nil {
					fmt.Println(string(content))
				} else {
					fmt.Println("No README found for this scenario.")
				}
				return
			}

			fmt.Printf("Unknown help topic: %s\n", args[0])
			rootCmd.Help()
		},
	})
}

func initConfig() {
	// Load .env file if it exists
	_ = godotenv.Load()
}
