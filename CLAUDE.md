# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains the CC Alias Tool - a utility that creates a `cc` command-line shortcut for launching Claude Code with custom environment configurations, specifically designed for OpenTelemetry integration. The project includes a modern multi-page website with comprehensive documentation.

## Key Components

- **create_cc_alias.sh**: Main installation script that sets up the `cc` alias in ~/.zprofile
- **Multi-page Website**: Modern documentation site with the following pages:
  - **index.html**: Homepage with features overview and quick install
  - **requirements.html**: System requirements and verification
  - **installation.html**: Step-by-step installation guides with tabs
  - **documentation.html**: Comprehensive usage and configuration docs
  - **troubleshooting.html**: Solutions to common issues
  - **disclaimer.html**: Legal information and license details
- **styles.css**: Main stylesheet with modern design system and purple/cyan theme
- **pages.css**: Additional styles for inner pages
- **scripts.js**: JavaScript for navigation, mobile menu, and interactivity
- **image.png**: Brand image showcasing the CC Alias tool
- **LICENSE**: CC0 1.0 Universal (public domain dedication)

## Common Commands

### Testing the Installation Script
```bash
# Make script executable and run
chmod +x create_cc_alias.sh
./create_cc_alias.sh

# Quick install (one-liner)
curl -s https://raw.githubusercontent.com/netors/cc-alias/main/create_cc_alias.sh | bash
```

### Testing the Generated Alias
```bash
# After installation, reload profile
source ~/.zprofile

# Test the cc command
cc --help
```

### Development Commands
```bash
# Serve website locally for testing
python -m http.server 8000
# Open http://localhost:8000

# Check all pages for broken links
# Manual testing recommended for cross-page navigation
```

## Architecture

The script creates a shell function that:
1. Loads environment variables from ~/.env.cc
2. Tests connectivity to OTEL endpoint if configured (using netcat)
3. Launches the Claude binary with the loaded environment

The function handles:
- Environment variable validation (skips invalid lines)
- OTEL endpoint connectivity checks with user prompts for failure handling
- Both interactive and non-interactive modes for CI/automation

## Environment Configuration

The tool creates ~/.env.cc with OTEL configuration variables:
- `CLAUDE_CODE_ENABLE_TELEMETRY`: Enable/disable telemetry
- `OTEL_METRICS_EXPORTER` / `OTEL_LOGS_EXPORTER`: Set to "otlp"
- `OTEL_EXPORTER_OTLP_ENDPOINT`: OTEL collector endpoint (default: http://localhost:4317)
- `OTEL_METRIC_EXPORT_INTERVAL` / `OTEL_LOGS_EXPORT_INTERVAL`: Export intervals in milliseconds
- `OTEL_LOG_USER_PROMPTS`: Enable user prompt logging

Reference: https://github.com/ColeMurray/claude-code-otel/blob/main/CLAUDE_OBSERVABILITY.md

## Website Architecture

The project features a modern, responsive multi-page website with:
- **Design System**: CSS variables for consistent theming with purple/cyan color scheme
- **Navigation**: Fixed navbar with mobile hamburger menu and breadcrumb navigation
- **Content Organization**: Tabbed interfaces, step-by-step guides, and card-based layouts
- **Interactive Elements**: Copy-to-clipboard functionality, hover animations, scroll effects
- **Responsive Design**: Mobile-first approach with breakpoints for tablets and desktop
- **Accessibility**: Semantic HTML, ARIA labels, and keyboard navigation support

## Dependencies

Essential:
- Claude binary installed and in PATH
- Node.js v22+
- macOS with zsh shell

Optional:
- netcat (nc) for connectivity testing
- Docker for running OTEL collector

## Development Notes

- All install commands now point to the main branch: `https://raw.githubusercontent.com/netors/cc-alias/main/create_cc_alias.sh`
- Footer includes attribution to @eruysanchez and links to CC0 license
- Brand image (image.png) is integrated into the homepage for visual consistency
- Cross-page navigation uses relative links for seamless browsing
- All pages follow consistent footer structure with proper licensing information