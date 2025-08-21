# CC Alias Tool

A simple utility to create a `cc` command-line shortcut for launching Claude Code with custom environment configurations and OpenTelemetry integration.

## 🌐 Documentation Website

Visit our comprehensive documentation site with installation guides, troubleshooting, and configuration details:

**[CC Alias Documentation](https://netors.github.io/cc-alias/)**

## 🚀 Quick Install

```bash
curl -s https://raw.githubusercontent.com/netors/cc-alias/main/create_cc_alias.sh | bash
```

> ⚠️ **Always review scripts before piping to bash.** See our [installation guide](https://netors.github.io/cc-alias/installation.html) for safer manual installation.

## 📋 What It Does

This tool creates a convenient `cc` alias that:
- Loads custom environment variables from `~/.env.cc`
- Checks connectivity to OpenTelemetry collectors
- Launches Claude Code with telemetry integration
- Enables monitoring of Claude Code metrics in Grafana dashboards

## 🔧 Requirements

### Essential
- **Claude Code CLI** - Must be [installed and in PATH](https://docs.anthropic.com/en/docs/claude-code/overview)
- **Node.js v22+** - Required for Claude Code
- **macOS with zsh** - Script is designed for macOS/zsh environments

### Optional
- **Docker** - For running the OTEL collector
- **netcat (`nc`)** - For connectivity testing
- **[claude-code-otel](https://github.com/ColeMurray/claude-code-otel)** - Pre-configured Docker container with Grafana dashboards

## 📦 Manual Installation

1. **Download the script:**
   ```bash
   curl -o create_cc_alias.sh https://raw.githubusercontent.com/netors/cc-alias/main/create_cc_alias.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x create_cc_alias.sh
   ```

3. **Run the installer:**
   ```bash
   ./create_cc_alias.sh
   ```

4. **Activate the alias:**
   ```bash
   source ~/.zprofile
   ```

## 💻 Usage

Once installed, launch Claude Code with:
```bash
cc
```

Pass arguments as usual:
```bash
cc --help
cc path/to/project
```

## ⚙️ Configuration

Edit `~/.env.cc` to customize your environment:

```bash
# Enable telemetry
CLAUDE_CODE_ENABLE_TELEMETRY=1

# Configure exporters
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp

# Set OTLP endpoint
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

# Adjust export intervals (milliseconds)
OTEL_METRIC_EXPORT_INTERVAL=10000
OTEL_LOGS_EXPORT_INTERVAL=5000

# Enable user prompts logging
OTEL_LOG_USER_PROMPTS=1
```

## 📊 OpenTelemetry Integration

For full observability:

1. Set up [claude-code-otel](https://github.com/ColeMurray/claude-code-otel) Docker container
2. Ensure Docker is running
3. Launch Claude Code with `cc`
4. View metrics in Grafana at `http://localhost:3000`

See the [Claude Observability documentation](https://github.com/ColeMurray/claude-code-otel/blob/main/CLAUDE_OBSERVABILITY.md) for detailed configuration options.

## 🔍 How It Works

The script:
1. Creates `~/.env.cc` configuration file if it doesn't exist
2. Adds a `cc()` function to your `~/.zprofile`
3. When you run `cc`, the function:
   - Loads environment variables from `~/.env.cc`
   - Tests OTEL endpoint connectivity (if configured)
   - Launches Claude Code with the custom environment

## 🐛 Troubleshooting

### Connection Errors
Ensure your OTEL collector is running at the configured endpoint.

### Missing Dependencies
- Install Node.js 22+: `brew install node@22`
- Install netcat: `brew install netcat`

### Update Existing Alias
Run the script again - it will detect and prompt to update the existing function.

### Manual Cleanup
Remove the `cc()` function from `~/.zprofile` if needed.

## 📄 License

[CC0 1.0 Universal (Public Domain Dedication)](https://github.com/netors/cc-alias/blob/main/LICENSE) - This work is in the public domain. You are free to use, modify, and distribute without any restrictions.

Created by [@eruysanchez](https://x.com/eruysanchez)

## 🔗 Resources

- **[Documentation Website](https://netors.github.io/cc-alias/)** - Complete installation guides and documentation
- **[Requirements](https://netors.github.io/cc-alias/requirements.html)** - System requirements and verification
- **[Troubleshooting](https://netors.github.io/cc-alias/troubleshooting.html)** - Solutions to common issues
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Claude Code OTEL Project](https://github.com/ColeMurray/claude-code-otel)

## 🎨 Website Features

Our documentation website includes:
- 📱 **Responsive Design** - Works perfectly on mobile, tablet, and desktop
- 🎨 **Modern UI** - Clean design with purple gradient theme matching our brand
- 📖 **Comprehensive Docs** - Step-by-step guides, troubleshooting, and configuration
- 🔍 **Easy Navigation** - Fixed navbar, breadcrumbs, and cross-page linking
- 📋 **Copy Commands** - One-click copying of installation commands
- ⚡ **Fast Loading** - Optimized for quick access to information