#!/bin/bash

# Platform Adapter Script
# Provides cross-platform compatibility wrappers for common commands

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Linux*)     export PLATFORM=Linux;;
        Darwin*)    export PLATFORM=macOS;;
        CYGWIN*)    export PLATFORM=Windows;;
        MINGW*)     export PLATFORM=Windows;;
        *)          export PLATFORM="Unknown";;
    esac
}

# Initialize platform detection
detect_platform

# Portable date function
portable_date() {
    local format="${1:-'+%Y-%m-%d %H:%M:%S'}"
    
    case "$PLATFORM" in
        macOS)
            # macOS uses BSD date
            if command -v gdate >/dev/null 2>&1; then
                gdate "$format"
            else
                date "$format"
            fi
            ;;
        *)
            # Linux and Windows use GNU date
            date "$format"
            ;;
    esac
}

# Portable sed function
portable_sed() {
    case "$PLATFORM" in
        macOS)
            # macOS uses BSD sed
            if command -v gsed >/dev/null 2>&1; then
                gsed "$@"
            else
                sed -E "$@"
            fi
            ;;
        *)
            # Linux and Windows use GNU sed
            sed -r "$@"
            ;;
    esac
}

# Portable grep function
portable_grep() {
    case "$PLATFORM" in
        macOS)
            # macOS uses BSD grep
            if command -v ggrep >/dev/null 2>&1; then
                ggrep "$@"
            else
                grep -E "$@"
            fi
            ;;
        *)
            # Linux and Windows use GNU grep
            grep -E "$@"
            ;;
    esac
}

# Portable find function
portable_find() {
    case "$PLATFORM" in
        macOS)
            # macOS uses BSD find
            if command -v gfind >/dev/null 2>&1; then
                gfind "$@"
            else
                find "$@"
            fi
            ;;
        *)
            # Linux and Windows use GNU find
            find "$@"
            ;;
    esac
}

# Portable stat function
portable_stat() {
    local file="$1"
    local format="${2:-'%s'}"
    
    case "$PLATFORM" in
        macOS)
            # macOS uses BSD stat
            if command -v gstat >/dev/null 2>&1; then
                gstat -c "$format" "$file"
            else
                stat -f "$format" "$file"
            fi
            ;;
        *)
            # Linux and Windows use GNU stat
            stat -c "$format" "$file"
            ;;
    esac
}

# Portable realpath function
portable_realpath() {
    local path="$1"
    
    case "$PLATFORM" in
        macOS)
            # macOS may not have realpath
            if command -v grealpath >/dev/null 2>&1; then
                grealpath "$path"
            elif command -v realpath >/dev/null 2>&1; then
                realpath "$path"
            else
                # Fallback using Python
                python3 -c "import os; print(os.path.realpath('$path'))"
            fi
            ;;
        *)
            # Linux and Windows have realpath
            realpath "$path"
            ;;
    esac
}

# Portable readlink function
portable_readlink() {
    local path="$1"
    
    case "$PLATFORM" in
        macOS)
            # macOS uses BSD readlink
            if command -v greadlink >/dev/null 2>&1; then
                greadlink -f "$path"
            else
                readlink "$path"
            fi
            ;;
        *)
            # Linux and Windows use GNU readlink
            readlink -f "$path"
            ;;
    esac
}

# Portable timeout function
portable_timeout() {
    local duration="$1"
    shift
    
    case "$PLATFORM" in
        macOS)
            # macOS may not have timeout
            if command -v gtimeout >/dev/null 2>&1; then
                gtimeout "$duration" "$@"
            elif command -v timeout >/dev/null 2>&1; then
                timeout "$duration" "$@"
            else
                # Fallback without timeout
                echo "Warning: timeout not available on this platform" >&2
                "$@"
            fi
            ;;
        *)
            # Linux and Windows have timeout
            timeout "$duration" "$@"
            ;;
    esac
}

# Path normalization function
normalize_path() {
    local path="$1"
    
    case "$PLATFORM" in
        Windows)
            # Convert backslashes to forward slashes
            echo "${path//\\//}"
            ;;
        *)
            # Unix-like systems
            echo "$path"
            ;;
    esac
}

# Get temporary directory
get_temp_dir() {
    case "$PLATFORM" in
        Windows)
            echo "${TEMP:-/tmp}"
            ;;
        *)
            echo "${TMPDIR:-/tmp}"
            ;;
    esac
}

# Check if running in CI environment
is_ci() {
    [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${JENKINS_URL:-}" ]]
}

# Get number of CPU cores
get_cpu_cores() {
    case "$PLATFORM" in
        Linux)
            nproc
            ;;
        macOS)
            sysctl -n hw.ncpu
            ;;
        Windows)
            echo "${NUMBER_OF_PROCESSORS:-1}"
            ;;
        *)
            echo "1"
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install platform-specific dependencies
install_dependencies() {
    case "$PLATFORM" in
        Linux)
            echo "Linux dependencies should be installed via package manager"
            echo "Common packages: bash, coreutils, findutils, grep, sed, git"
            ;;
        macOS)
            echo "macOS: Consider installing GNU coreutils for better compatibility:"
            echo "  brew install coreutils gnu-sed gnu-grep findutils"
            echo "  Add to PATH: export PATH=\"/usr/local/opt/coreutils/libexec/gnubin:\$PATH\""
            ;;
        Windows)
            echo "Windows: Use Git Bash or WSL for best compatibility"
            echo "Required: Git for Windows with Unix tools"
            ;;
        *)
            echo "Unknown platform: Manual dependency installation required"
            ;;
    esac
}

# Platform-specific setup
setup_platform() {
    case "$PLATFORM" in
        macOS)
            # Set up GNU tools path if available
            if [[ -d "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
                export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
            fi
            if [[ -d "/usr/local/opt/gnu-sed/libexec/gnubin" ]]; then
                export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
            fi
            if [[ -d "/usr/local/opt/gnu-grep/libexec/gnubin" ]]; then
                export PATH="/usr/local/opt/gnu-grep/libexec/gnubin:$PATH"
            fi
            if [[ -d "/usr/local/opt/findutils/libexec/gnubin" ]]; then
                export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
            fi
            ;;
        Windows)
            # Set up Windows-specific environment
            export PATH="$PATH:/usr/bin:/mingw64/bin"
            ;;
    esac
}

# Platform information
show_platform_info() {
    echo "Platform: $PLATFORM"
    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Kernel: $(uname -r)"
    echo "Shell: ${SHELL:-unknown}"
    echo "CPU cores: $(get_cpu_cores)"
    echo "Temp dir: $(get_temp_dir)"
    echo "CI environment: $(is_ci && echo "Yes" || echo "No")"
}

# Export functions for use in other scripts
export -f detect_platform
export -f portable_date
export -f portable_sed
export -f portable_grep
export -f portable_find
export -f portable_stat
export -f portable_realpath
export -f portable_readlink
export -f portable_timeout
export -f normalize_path
export -f get_temp_dir
export -f is_ci
export -f get_cpu_cores
export -f command_exists
export -f install_dependencies
export -f setup_platform
export -f show_platform_info

# Initialize platform setup
setup_platform

# If script is run directly, show platform info
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_platform_info
fi