#!/bin/bash
# Helper functions for chezmoi scripts with clean output and logging
# This file is sourced by chezmoi installation scripts

# Log file location
export CHEZMOI_LOG_DIR="${HOME}/.local/log/chezmoi"
export CHEZMOI_LOG_FILE="${CHEZMOI_LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log"
export CHEZMOI_LATEST_LOG="${CHEZMOI_LOG_DIR}/latest.log"

# Terminal colors
export CLR_RESET='\033[0m'
export CLR_BOLD='\033[1m'
export CLR_DIM='\033[2m'
export CLR_GREEN='\033[32m'
export CLR_YELLOW='\033[33m'
export CLR_BLUE='\033[34m'
export CLR_CYAN='\033[36m'
export CLR_RED='\033[31m'
export CLR_MAGENTA='\033[35m'

# Progress bar characters
export PROG_FILL="█"
export PROG_EMPTY="░"
export PROG_SPIN=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Initialize logging
init_logging() {
    mkdir -p "$CHEZMOI_LOG_DIR"
    touch "$CHEZMOI_LOG_FILE"
    ln -sf "$CHEZMOI_LOG_FILE" "$CHEZMOI_LATEST_LOG"
    echo "=== Chezmoi installation started at $(date) ===" >> "$CHEZMOI_LOG_FILE"
}

# Log to file only (no terminal output)
log_silent() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$CHEZMOI_LOG_FILE"
}

# Log section header
log_section() {
    local name="$1"
    echo "" >> "$CHEZMOI_LOG_FILE"
    echo "========================================" >> "$CHEZMOI_LOG_FILE"
    echo "  $name" >> "$CHEZMOI_LOG_FILE"
    echo "========================================" >> "$CHEZMOI_LOG_FILE"
}

# Run a command silently, logging output to file
# Usage: run_silent "description" command args...
run_silent() {
    local desc="$1"
    shift
    log_silent "Running: $*"
    if "$@" >> "$CHEZMOI_LOG_FILE" 2>&1; then
        log_silent "SUCCESS: $desc"
        return 0
    else
        local exit_code=$?
        log_silent "FAILED ($exit_code): $desc"
        return $exit_code
    fi
}

# Print a status line (single line, no newline for updates)
print_status() {
    local symbol="$1"
    local color="$2"
    local message="$3"
    printf "\r\033[K  ${color}${symbol}${CLR_RESET} ${message}"
}

# Print a completed step with checkmark
print_done() {
    local message="$1"
    printf "\r\033[K  ${CLR_GREEN}✓${CLR_RESET} ${message}\n"
}

# Print a failed step
print_fail() {
    local message="$1"
    printf "\r\033[K  ${CLR_RED}✗${CLR_RESET} ${message}\n"
}

# Print a warning
print_warn() {
    local message="$1"
    printf "  ${CLR_YELLOW}!${CLR_RESET} ${message}\n"
}

# Print section header
print_header() {
    local title="$1"
    printf "\n${CLR_BOLD}${CLR_BLUE}▸${CLR_RESET} ${CLR_BOLD}${title}${CLR_RESET}\n"
}

# Print a subtle info message
print_info() {
    local message="$1"
    printf "  ${CLR_DIM}${message}${CLR_RESET}\n"
}

# Show spinner while a command runs
# Usage: with_spinner "message" command args...
with_spinner() {
    local message="$1"
    shift
    local cmd=("$@")
    local spin_idx=0
    local pid
    
    # Start the command in background
    "${cmd[@]}" >> "$CHEZMOI_LOG_FILE" 2>&1 &
    pid=$!
    
    # Show spinner while command runs
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r\033[K  ${CLR_CYAN}${PROG_SPIN[$spin_idx]}${CLR_RESET} ${message}"
        spin_idx=$(( (spin_idx + 1) % ${#PROG_SPIN[@]} ))
        sleep 0.1
    done
    
    # Get exit status
    wait "$pid"
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        print_done "$message"
    else
        print_fail "$message"
        log_silent "Command failed with exit code $exit_code: ${cmd[*]}"
    fi
    
    return $exit_code
}

# Show a progress bar for multi-step operations
# Usage: show_progress current total "message"
show_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    local width=20
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    local bar=""
    
    for ((i=0; i<filled; i++)); do bar+="$PROG_FILL"; done
    for ((i=0; i<empty; i++)); do bar+="$PROG_EMPTY"; done
    
    printf "\r\033[K  ${CLR_CYAN}${bar}${CLR_RESET} ${message} (${current}/${total})"
}

# Complete a progress bar
complete_progress() {
    local message="$1"
    printf "\r\033[K"
    print_done "$message"
}

# Run multiple steps with a single progress indicator
# Usage: run_steps "Overall task" "step1 desc" cmd1 args... -- "step2 desc" cmd2 args... --
run_steps() {
    local overall="$1"
    shift
    
    local steps=()
    local current_step=()
    local current_desc=""
    
    # Parse steps
    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            if [[ -n "$current_desc" ]]; then
                steps+=("$current_desc|${current_step[*]}")
            fi
            current_step=()
            current_desc=""
        elif [[ -z "$current_desc" ]]; then
            current_desc="$arg"
        else
            current_step+=("$arg")
        fi
    done
    
    # Add last step if exists
    if [[ -n "$current_desc" ]]; then
        steps+=("$current_desc|${current_step[*]}")
    fi
    
    local total=${#steps[@]}
    local current=0
    local failed=0
    
    for step in "${steps[@]}"; do
        ((current++))
        local desc="${step%%|*}"
        local cmd="${step#*|}"
        
        show_progress "$current" "$total" "$desc"
        log_silent "Step $current/$total: $desc"
        log_silent "Running: $cmd"
        
        if eval "$cmd" >> "$CHEZMOI_LOG_FILE" 2>&1; then
            log_silent "Step completed successfully"
        else
            log_silent "Step failed"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        complete_progress "$overall"
        return 0
    else
        printf "\r\033[K"
        print_fail "$overall ($failed/$total steps failed)"
        return 1
    fi
}

# Wrapper for package installation commands to make them quiet
apt_install() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$@"
}

dnf_install() {
    sudo dnf install -y -q "$@"
}

yum_install() {
    sudo yum install -y -q "$@"
}

pacman_install() {
    sudo pacman -Sy --noconfirm --quiet "$@"
}

brew_install() {
    brew install --quiet "$@"
}

brew_cask_install() {
    brew install --cask --quiet "$@"
}

# Check if this is the first run (for initialization)
is_first_run() {
    [[ ! -f "$CHEZMOI_LOG_DIR/.initialized" ]]
}

# Mark as initialized
mark_initialized() {
    touch "$CHEZMOI_LOG_DIR/.initialized"
}

# Print log file location
print_log_location() {
    printf "\n${CLR_DIM}  Log: ${CHEZMOI_LATEST_LOG}${CLR_RESET}\n"
}

# Initialize on source if not already done
if [[ -z "${CHEZMOI_LOG_INITIALIZED:-}" ]]; then
    init_logging
    export CHEZMOI_LOG_INITIALIZED=1
fi
