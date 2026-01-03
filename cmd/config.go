package cmd

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
)

var configCmd = &cobra.Command{
	Use:   "config",
	Short: "Configure AWS credentials and whitelist",
}

var awsCmd = &cobra.Command{
	Use:   "aws",
	Short: "Configure AWS credentials",
	Run: func(cmd *cobra.Command, args []string) {
		reader := bufio.NewReader(os.Stdin)

		fmt.Print("AWS Access Key ID: ")
		accessKey, _ := reader.ReadString('\n')
		accessKey = strings.TrimSpace(accessKey)

		fmt.Print("AWS Secret Access Key: ")
		secretKey, _ := reader.ReadString('\n')
		secretKey = strings.TrimSpace(secretKey)

		fmt.Print("AWS Region (default: us-east-1): ")
		region, _ := reader.ReadString('\n')
		region = strings.TrimSpace(region)
		if region == "" {
			region = "us-east-1"
		}

		content := fmt.Sprintf("AWS_ACCESS_KEY_ID=%s\nAWS_SECRET_ACCESS_KEY=%s\nAWS_DEFAULT_REGION=%s\n", accessKey, secretKey, region)
		err := os.WriteFile(".env", []byte(content), 0600)
		if err != nil {
			fmt.Println("Error writing .env file:", err)
			return
		}
		fmt.Println("Configuration saved to .env")
	},
}

var whitelistCmd = &cobra.Command{
	Use:   "whitelist",
	Short: "Whitelist your IP address",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Whitelist feature not yet implemented. All traffic is currently allowed (0.0.0.0/0).")
	},
}

func init() {
	rootCmd.AddCommand(configCmd)
	configCmd.AddCommand(awsCmd)
	configCmd.AddCommand(whitelistCmd)
}
