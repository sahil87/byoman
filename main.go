package main

import (
	"byoman/internal/app"
	"fmt"
	"os"
)

func main() {
	if err := app.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
