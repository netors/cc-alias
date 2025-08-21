#!/usr/bin/env bash
#
# This script is provided for educational purposes and is free to use,
# modify, and distribute without any restrictions. It is offered "as is"
# without any warranty.
#
# create_cc_alias.sh
# ------------------
# This script creates a 'cc' alias function in your ~/.zprofile to launch
# Claude Code with custom environment variables loaded from ~/.env.cc.
#
#   Requirements
#   ------------
#     - The 'claude' binary must be installed and in your PATH
#     - Node.js version 22 or higher installed and in your PATH
#     - netcat ('nc') command available for connectivity testing (optional)
#     - The 'claude code otel' collector must be installed and running (optional)
#
#   Usage
#   -----
#     1. Download the script
#     2. Make it executable: chmod +x create_cc_alias.sh
#     3. Run it: ./create_cc_alias.sh
#     4. Open a new terminal window or run: source ~/.zprofile
#
#   What it does
#   ------------
#     1. Creates a ~/.env.cc file if it doesn't exist
#     2. Adds a 'cc' function to your ~/.zprofile
#     3. When you run 'cc', it:
#        - Loads environment variables from ~/.env.cc
#        - Tests connectivity to OTEL endpoint if configured
#        - Runs the 'claude' binary with the loaded environment
#
#   Customization
#   -------------
#   Edit ~/.env.cc to customize environment variables for your Claude Code sessions.
#   The variables set there will be loaded every time you use the 'cc' command.
#

# Exit immediately if any command fails
# Treat unset variables as errors
# Exit if any command in a pipe fails
set -euo pipefail

# Check if we're running in a pipe or non-interactive shell
NON_INTERACTIVE=0

# More robust interactivity check
if [[ ! -t 0 || ! -t 1 ]]; then
    NON_INTERACTIVE=1
fi

echo '
   ██████╗ ██████╗     █████╗ ██╗     ██╗ █████╗ ███████╗
  ██╔════╝██╔════╝    ██╔══██╗██║     ██║██╔══██╗██╔════╝
  ██║     ██║         ███████║██║     ██║███████║███████╗
  ██║     ██║         ██╔══██║██║     ██║██╔══██║╚════██║
  ╚██████╗╚██████╗    ██║  ██║███████╗██║██║  ██║███████║
   ╚═════╝ ╚═════╝    ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚══════╝
   ──────────────────────────────────────────────────────
   use cc to launch claude code with custom configuration
   ──────────────────────────────────────────────────────
                             follow me on x: @eruysanchez
'
echo "This script will create a 'cc' alias for the 'claude' binary."
echo "It works by appending a shell function to your ~/.zprofile file."
echo ""
if [[ $NON_INTERACTIVE -eq 1 ]]; then
    # In non-interactive mode, proceed automatically
    echo "Running in non-interactive mode, proceeding with installation..."
    REPLY="y"
else
    # In interactive mode, prompt for confirmation
    read -p "Do you want to proceed with the installation? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

echo "Proceeding with installation..."

# Check for claude binary
if ! command -v claude &> /dev/null; then
    echo "🛑  The 'claude' binary could not be found in your PATH."
    echo "Please install it before running this script."
    exit 1
fi

# Check for node version
MIN_NODE_VERSION="22"
if ! command -v node &> /dev/null; then
    echo "🛑  Node.js is not installed or not in your PATH."
    echo "Please install Node.js version ${MIN_NODE_VERSION} or higher."
    exit 1
fi

CURRENT_NODE_VERSION=$(node --version | sed 's/v//' | cut -d'.' -f1)
if ! command -v bc &> /dev/null; then
    echo "⚠️  'bc' command not found. Skipping precise Node.js version check."
    echo "   Please ensure you have Node.js ${MIN_NODE_VERSION} or higher installed."
else
    if (( $(echo "$CURRENT_NODE_VERSION < $MIN_NODE_VERSION" | bc -l) )); then
        echo "🛑  Your Node.js version is too old."
        echo "Please upgrade to version ${MIN_NODE_VERSION} or higher."
        exit 1
    fi
fi

# Check for netcat
if ! command -v nc &> /dev/null; then
    echo "⚠️  The 'nc' (netcat) command is not available."
    echo "   Connection testing will be skipped."
    NC_AVAILABLE=false
else
    NC_AVAILABLE=true
fi

#############################
# ENVIRONMENT FILE SETUP    #
#############################

# Path to the environment file
ENV_FILE="${HOME}/.env.cc"

# Create environment file if it doesn't exist
if [[ ! -f "${ENV_FILE}" ]]; then
    echo "Creating environment file at ${ENV_FILE}..."
    cat > "${ENV_FILE}" << 'ENVEOF'
# Claude Code Environment Configuration
# Reference: https://github.com/ColeMurray/claude-code-otel/blob/main/CLAUDE_OBSERVABILITY.md

# 1. Enable telemetry
CLAUDE_CODE_ENABLE_TELEMETRY=1

# 2. Choose exporters (both are optional - configure only what you need)
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp

# 3. Configure OTLP endpoint (for OTLP exporter)
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

# 4. Set authentication (if required)
# OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer your-token"

# 5. For debugging: reduce export intervals
OTEL_METRIC_EXPORT_INTERVAL=10000 # 10 seconds (default: 60000ms)
OTEL_LOGS_EXPORT_INTERVAL=5000 # 5 seconds (default: 5000ms)

# 6. Enable user prompts logging
OTEL_LOG_USER_PROMPTS=1
ENVEOF
    echo "✅ Created ${ENV_FILE}"
    echo "   You can customize this file to change your environment variables."
else
    echo "✅ Using existing environment file at ${ENV_FILE}"
fi


# Check if the script is continuing execution

# Binary to be called
BINARY="claude"

# Optional: add extra command line arguments that should always be passed
# to the binary, even if you supply your own. Leave empty if you don't.
DEFAULT_ARGS=()

#############################
# INTERNAL SECTION          #
#############################

PROFILE="${HOME}/.zprofile"          # the file we'll touch
ALIAS_NAME="cc"                      # the command you'll type

# Create a temporary file to store the function definition
TEMP_FUNC_FILE="$(mktemp /tmp/cc_function.XXXXXXXXXX)"
cat > "$TEMP_FUNC_FILE" << 'EOF'
# ------------------------------
# Auto-generated by create_cc_alias.sh
#   * Loads environment from ~/.env.cc
#   * Calls claude
# ------------------------------
cc() {
  # Load environment variables from file
  if [[ -f "${HOME}/.env.cc" ]]; then
    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Skip comments and empty lines
      [[ "$line" =~ ^[[:space:]]*#.*$ || -z "$line" ]] && continue
      
      # Check if the line contains a valid environment variable assignment
      if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
        # Export each variable
        export "$line"
      else
        # If not a comment or empty, but invalid format, print warning
        [[ $line =~ ^[[:space:]] ]] || echo "⚠️  Warning: Ignoring invalid line in ~/.env.cc: $line"
      fi
    done < "${HOME}/.env.cc"
  else
    echo "⚠️  Warning: ~/.env.cc file not found. Running without custom environment."
  fi

  # Check if we need to verify OTEL connection
  if [[ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ]]; then
    # Parse the URL to extract host and port
    local host=$(echo "$OTEL_EXPORTER_OTLP_ENDPOINT" | sed -E 's|^https?://([^:/]+)(:[0-9]+)?.*|\1|')
    local port=$(echo "$OTEL_EXPORTER_OTLP_ENDPOINT" | sed -E 's|^https?://[^:]+:([0-9]+).*|\1|')
    
    # Check if host was successfully extracted
    if [[ "$host" == "$OTEL_EXPORTER_OTLP_ENDPOINT" ]]; then
      echo "⚠️  Warning: Could not parse host from OTEL_EXPORTER_OTLP_ENDPOINT"
      echo "   Value: $OTEL_EXPORTER_OTLP_ENDPOINT"
      echo "   Expected format: http://hostname:port"
    else
      # Check if port was successfully extracted, default to 4317 if not
      if [[ "$port" == "$OTEL_EXPORTER_OTLP_ENDPOINT" ]]; then
        # Port wasn't in the URL, use default
        port="4317"
      fi
      
      # Check if netcat is available for connection test
      if command -v nc &>/dev/null; then
        # Check if the endpoint is reachable
        echo "Checking connection to OTEL collector at $host:$port..."
        if ! nc -z -w 2 "$host" "$port" &>/dev/null; then
          echo "⚠️  Warning: Could not connect to OTEL collector at $host:$port"
          echo "   The claude-code-otel listener does not appear to be running."
          
          if [ $NON_INTERACTIVE -eq 1 ]; then
            # In non-interactive mode, continue anyway
            echo "Running in non-interactive mode, continuing with OTEL environment setup..."
            OTEL_RESPONSE="c"
          else
            # In interactive mode, prompt the user
            read -p "Would you like to (s)kip setting OTEL environment variables, (r)etry, or (c)ontinue anyway? [s/r/c] " -n 1 -r
            echo ""
            OTEL_RESPONSE=$REPLY
          fi
          
          if [[ $OTEL_RESPONSE =~ ^[Ss]$ ]]; then
            echo "Skipping OTEL environment setup."
            # Unset all OTEL variables
            unset CLAUDE_CODE_ENABLE_TELEMETRY OTEL_METRICS_EXPORTER OTEL_LOGS_EXPORTER 
            unset OTEL_EXPORTER_OTLP_PROTOCOL OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_HEADERS
            unset OTEL_METRIC_EXPORT_INTERVAL OTEL_LOGS_EXPORT_INTERVAL OTEL_LOG_USER_PROMPTS
          elif [[ $OTEL_RESPONSE =~ ^[Rr]$ ]]; then
            echo "Please start the OTEL collector and then run cc again."
            return 1
          else
            # For continue, we'll just proceed with the environment as is
            echo "Continuing with OTEL environment setup despite connection failure."
          fi
        else
          echo "✅ OTEL collector is reachable at $host:$port"
        fi
      else
        echo "⚠️  Note: 'nc' command not available, skipping connection check to $host:$port"
      fi
    fi
  fi

  # Execute the binary with any supplied arguments plus defaults
  claude ${DEFAULT_ARGS[*]} "$@"
}
EOF

# Replace cc with the actual alias name if it's different
sed -i "" "s/^cc() {/${ALIAS_NAME}() {/" "$TEMP_FUNC_FILE"

# Read the function definition from the temporary file
FUNC_DEFINITION="$(cat "$TEMP_FUNC_FILE")"

# Clean up temporary file
rm "$TEMP_FUNC_FILE"

# Check whether we already added it - use a more comprehensive check
if grep -q "^${ALIAS_NAME}()" "${PROFILE}" 2>/dev/null || grep -q "function ${ALIAS_NAME}" "${PROFILE}" 2>/dev/null; then
  echo "✅  The '${ALIAS_NAME}' function already exists in ${PROFILE}"
  
  if [[ $NON_INTERACTIVE -eq 1 ]]; then
    # In non-interactive mode, exit with helpful message
    echo "ℹ️  When running in non-interactive mode, existing functions are not updated."
    echo "ℹ️  If you need to reinstall, please remove the ${ALIAS_NAME}() function from ${PROFILE} manually."
    exit 0
  else
    # In interactive mode, prompt user
    read -p "Would you like to update the existing function? (y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Keeping existing function definition."
      exit 0
    fi
    
    # Check if profile is a regular file before trying to modify it
    if [[ ! -f "${PROFILE}" ]]; then
      echo "❌ Error: ${PROFILE} is not a regular file. Cannot update."
      echo "Please check your profile file and try again."
      exit 1
    fi
    
    # Remove the existing function definition (handle both styles of declaration)
    sed -i "" -e "/^${ALIAS_NAME}()/,/^}/d" -e "/function ${ALIAS_NAME}/,/^}/d" "${PROFILE}" 2>/dev/null
    if [[ $? -ne 0 ]]; then
      echo "❌ Error: Could not update existing function in ${PROFILE}."
      echo "Please remove the ${ALIAS_NAME}() function manually and try again."
      exit 1
    fi
    
    echo "Removed existing function definition."
  fi
  
  # Append the new function definition
  echo "${FUNC_DEFINITION}" >> "${PROFILE}"
  echo "✅  Updated '${ALIAS_NAME}' function in ${PROFILE}"

else
  # Append the function definition to the profile file
  echo "${FUNC_DEFINITION}" >> "${PROFILE}"
  echo "✅  Added '${ALIAS_NAME}' function to ${PROFILE}"
fi

echo "📦  To activate it now, run: source \"${PROFILE}\""
echo "💡  Next time you open a terminal, just type '${ALIAS_NAME}' and hit Enter."
echo "💡  Customize your environment variables in ~/.env.cc"
