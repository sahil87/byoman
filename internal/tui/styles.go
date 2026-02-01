package tui

import (
	"os"

	"github.com/charmbracelet/lipgloss"
)

var (
	// Colors - respect NO_COLOR env var
	noColor = os.Getenv("NO_COLOR") != ""

	// Primary colors
	primaryColor   = lipgloss.Color("205") // Pink/magenta
	secondaryColor = lipgloss.Color("240") // Gray
	errorColor     = lipgloss.Color("196") // Red
	successColor   = lipgloss.Color("82")  // Green

	// Title style
	TitleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(primaryColor).
			MarginBottom(1)

	// List item styles
	ItemStyle = lipgloss.NewStyle().
			PaddingLeft(2)

	SelectedItemStyle = lipgloss.NewStyle().
				Foreground(primaryColor).
				Bold(true)

	// Cursor style
	CursorStyle = lipgloss.NewStyle().
			Foreground(primaryColor).
			Bold(true)

	// Session status styles
	AttachedStyle = lipgloss.NewStyle().
			Foreground(successColor)

	DetachedStyle = lipgloss.NewStyle().
			Foreground(secondaryColor)

	// Help/footer style
	HelpStyle = lipgloss.NewStyle().
			Foreground(secondaryColor).
			MarginTop(1)

	// Prompt style for confirmations and inputs
	PromptStyle = lipgloss.NewStyle().
			Foreground(primaryColor).
			Bold(true)

	// Error style
	ErrorStyle = lipgloss.NewStyle().
			Foreground(errorColor).
			Bold(true)

	// Dim style for secondary info
	DimStyle = lipgloss.NewStyle().
			Foreground(secondaryColor)
)

func init() {
	if noColor {
		// Reset all colors for NO_COLOR compliance
		TitleStyle = lipgloss.NewStyle().Bold(true).MarginBottom(1)
		ItemStyle = lipgloss.NewStyle().PaddingLeft(2)
		SelectedItemStyle = lipgloss.NewStyle().Bold(true)
		CursorStyle = lipgloss.NewStyle().Bold(true)
		AttachedStyle = lipgloss.NewStyle()
		DetachedStyle = lipgloss.NewStyle()
		HelpStyle = lipgloss.NewStyle().MarginTop(1)
		PromptStyle = lipgloss.NewStyle().Bold(true)
		ErrorStyle = lipgloss.NewStyle().Bold(true)
		DimStyle = lipgloss.NewStyle()
	}
}
