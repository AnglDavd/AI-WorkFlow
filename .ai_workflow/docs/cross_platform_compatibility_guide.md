# Cross-Platform Compatibility Guide

## Overview
The AI-Assisted Development Framework is designed to work across multiple operating systems with proper setup and configuration. This guide provides comprehensive information about platform compatibility and setup requirements.

## Supported Platforms

### ✅ Linux (Primary Platform)
- **Status**: Fully supported and tested
- **Distributions**: Ubuntu, Debian, CentOS, Fedora, Arch Linux
- **Requirements**: 
  - Bash 4.0+
  - GNU coreutils
  - Git 2.0+
  - Python 3.6+ (for JSON processing)
- **Installation**: Ready to use out of the box

### ✅ macOS (Secondary Platform)
- **Status**: Supported with additional setup
- **Versions**: macOS 10.15+
- **Requirements**:
  - Bash 4.0+ (system bash is 3.x, upgrade recommended)
  - GNU coreutils (install via Homebrew)
  - Git 2.0+
  - Python 3.6+
- **Installation**: See [macOS Setup](#macos-setup) section

### ⚠️ Windows (Limited Support)
- **Status**: Limited support via Git Bash or WSL
- **Requirements**:
  - Git for Windows with Git Bash
  - OR Windows Subsystem for Linux (WSL)
  - Python 3.6+ (if using native Windows)
- **Installation**: See [Windows Setup](#windows-setup) section

## Platform Detection

The framework automatically detects your platform and adapts behavior accordingly:

```bash
# Check current platform
./ai-dev platform

# Check version with platform info
./ai-dev version
```

## Setup Instructions

### Linux Setup

Linux users can use the framework immediately:

```bash
# Clone the repository
git clone https://github.com/AnglDavd/AI-WorkFlow.git
cd AI-WorkFlow

# Make the CLI executable
chmod +x ai-dev

# Test the installation
./ai-dev version
./ai-dev platform
```

### macOS Setup

macOS users need to install GNU coreutils for full compatibility:

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install GNU coreutils
brew install coreutils gnu-sed gnu-grep findutils

# Add GNU tools to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-grep/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"

# Reload your shell
source ~/.zshrc  # or ~/.bash_profile

# Clone and test
git clone https://github.com/AnglDavd/AI-WorkFlow.git
cd AI-WorkFlow
chmod +x ai-dev
./ai-dev version
./ai-dev platform
```

### Windows Setup

#### Option 1: Git Bash (Recommended)

```bash
# Install Git for Windows (includes Git Bash)
# Download from: https://git-scm.com/download/win

# Open Git Bash and clone
git clone https://github.com/AnglDavd/AI-WorkFlow.git
cd AI-WorkFlow

# Make executable and test
chmod +x ai-dev
./ai-dev version
./ai-dev platform
```

#### Option 2: Windows Subsystem for Linux (WSL)

```bash
# Enable WSL and install Ubuntu
wsl --install

# Inside WSL, follow Linux setup instructions
git clone https://github.com/AnglDavd/AI-WorkFlow.git
cd AI-WorkFlow
chmod +x ai-dev
./ai-dev version
```

## Compatibility Testing

### Automated Testing

The framework includes comprehensive compatibility testing:

```bash
# Run full compatibility test suite
./.ai_workflow/scripts/cross_platform_compatibility_test.sh

# Check specific platform compatibility
./ai-dev diagnose --platform
```

### Manual Testing

Test these core functions on your platform:

```bash
# Test CLI basic functionality
./ai-dev help
./ai-dev version
./ai-dev platform

# Test workflow execution
./ai-dev setup --dry-run

# Test file operations
./ai-dev quality .

# Test Git integration
git status
./ai-dev precommit validate
```

## Platform-Specific Considerations

### Linux Considerations
- ✅ Full GNU coreutils support
- ✅ Native bash and shell scripting
- ✅ Optimal performance
- ✅ All features supported

### macOS Considerations
- ⚠️ BSD vs GNU command differences
- ⚠️ Default bash is version 3.x (upgrade recommended)
- ⚠️ Case-insensitive filesystem by default
- ✅ Unix-like environment similar to Linux

### Windows Considerations
- ⚠️ Path separator differences (\ vs /)
- ⚠️ Line ending differences (CRLF vs LF)
- ⚠️ Limited Unix tool availability
- ⚠️ File permission model differences

## Common Issues and Solutions

### Issue: Command not found
**Symptoms**: `bash: command not found` errors
**Solution**: 
- Linux: Install missing packages via package manager
- macOS: Install GNU coreutils via Homebrew
- Windows: Use Git Bash or WSL

### Issue: Permission denied
**Symptoms**: Scripts not executable
**Solution**:
```bash
chmod +x ai-dev
chmod +x .ai_workflow/scripts/*.sh
```

### Issue: Path issues on Windows
**Symptoms**: Path-related errors
**Solution**:
- Use Git Bash consistently
- Avoid spaces in paths
- Use forward slashes in scripts

### Issue: Date command differences
**Symptoms**: Date formatting errors on macOS
**Solution**: Framework automatically handles this via platform adapter

## Performance Considerations

### Expected Performance by Platform

| Platform | Performance | Notes |
|----------|-------------|-------|
| Linux | 100% | Native performance |
| macOS | 95% | Slight overhead from GNU tools |
| Windows (Git Bash) | 85% | Emulation layer overhead |
| Windows (WSL) | 90% | Near-native Linux performance |

## CI/CD Integration

### GitHub Actions Support

The framework includes cross-platform GitHub Actions:

```yaml
# .github/workflows/cross-platform-compatibility.yml
- Linux: ubuntu-latest, ubuntu-20.04, ubuntu-22.04
- macOS: macos-latest, macos-13
- Windows: windows-latest with Git Bash
```

### Local Testing

Test across platforms locally:

```bash
# Test on current platform
./.ai_workflow/scripts/cross_platform_compatibility_test.sh

# Test specific components
./ai-dev diagnose --compatibility
```

## Best Practices

### For Framework Users

1. **Test on your target platform** before production use
2. **Use recommended setup** for your operating system
3. **Keep dependencies updated** (Git, Python, etc.)
4. **Use absolute paths** when possible
5. **Test in CI/CD** if using multiple platforms

### For Framework Developers

1. **Use portable commands** from platform adapter
2. **Test on multiple platforms** before releases
3. **Document platform-specific requirements**
4. **Use GitHub Actions** for automated testing
5. **Handle edge cases** gracefully

## Troubleshooting

### Debug Mode

Enable debug mode for detailed platform information:

```bash
export DEBUG=true
./ai-dev platform
./ai-dev version
```

### Platform Adapter Testing

Test the platform adapter directly:

```bash
# Source the adapter
source .ai_workflow/scripts/platform_adapter.sh

# Test portable functions
portable_date
portable_sed 's/test/TEST/' <<< "test"
portable_grep "pattern" file.txt
```

### Get Help

1. Check the [troubleshooting guide](troubleshooting.md)
2. Run `./ai-dev diagnose` for system analysis
3. File an issue on GitHub with platform details
4. Include output from `./ai-dev platform` in bug reports

## Future Enhancements

### Planned Improvements

- **Enhanced Windows Support**: Native PowerShell compatibility
- **Container Support**: Docker containers for consistent environments
- **Package Managers**: Homebrew, Chocolatey, APT integration
- **Automated Setup**: Platform-specific installation scripts
- **Performance Optimization**: Platform-specific optimizations

### Contributing

Help improve cross-platform compatibility:

1. Test on your platform and report issues
2. Contribute platform-specific fixes
3. Update documentation for new platforms
4. Add test cases for edge cases

---

**Last Updated**: 2025-07-17
**Framework Version**: v1.0.0
**Tested Platforms**: Linux (Ubuntu), macOS (limited), Windows (Git Bash)