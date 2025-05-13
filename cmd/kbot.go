/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/spf13/cobra"
	"github.com/stianeikeland/go-rpio"
	telebot "gopkg.in/telebot.v4"
)

var (
	// Teletoken bot
	TeleToken = os.Getenv("TELE_TOKEN")
)

// TrafficSignal represents a traffic light signal with a GPIO pin and its state.
type TrafficSignal struct {
	Pin int
	On  bool
}

// Define the traffic signals and their corresponding GPIO pins.
var trafficSignals = map[string]TrafficSignal{
	"red":   {Pin: 17, On: false}, // Replace 17 with the actual GPIO pin for red
	"amber": {Pin: 27, On: false}, // Replace 27 with the actual GPIO pin for amber
	"green": {Pin: 22, On: false}, // Replace 22 with the actual GPIO pin for green
}

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"start"},
	Short:   "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {

		fmt.Printf("kbot %s started", appVersion)
		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})

		if err != nil {
			log.Fatalf("Please check TELE_TOKEN env variable. %s", err)
		}
		kbot.Handle(telebot.OnText, func(m telebot.Context) error {
			log.Printf("Received message: %s", m.Text())
			payload := m.Message().Payload

			switch payload {
			case "hello":
				return m.Send(fmt.Sprintf("Hello I'm Kbot %s!", appVersion))

			case "red", "amber", "green":
				signal := trafficSignals[payload]
				pin := rpio.Pin(signal.Pin)

				if !signal.On {
					pin.Output()
					pin.High()
					signal.On = true
				} else {
					pin.Low()
					pin.Input()
					signal.On = false
				}

				return m.Send(fmt.Sprintf("Switched %s light %s", payload, map[bool]string{true: "on", false: "off"}[signal.On]))

			default:
				return m.Send("Usage: /s red|amber|green")
			}
		})

		kbot.Start()

	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// kbotCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// kbotCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
