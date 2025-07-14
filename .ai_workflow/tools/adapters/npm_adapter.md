# NPM Tool Adapter

## Overview
This workflow adapter translates abstract NPM tool calls into concrete `npm` shell commands. It provides a standardized interface for NPM operations within the framework.

## Workflow Instructions

### For AI Agents
When you need to execute NPM operations through abstract calls, this adapter will:

1. **Parse the action and parameters** from the abstract call
2. **Generate the appropriate npm command** based on the action
3. **Return the command** for execution by the main tool engine
4. **Handle parameter validation** and error cases

### Adapter Function
```bash
# Main adapter function - called by execute_abstract_tool_call.md
execute_adapter() {
    local ACTION="$1"
    local PARAMS="$2"
    
    case "$ACTION" in
        "install")
            npm_install "$PARAMS"
            ;;
        "run_script")
            npm_run_script "$PARAMS"
            ;;
        "test")
            npm_test "$PARAMS"
            ;;
        "init")
            npm_init "$PARAMS"
            ;;
        "start")
            npm_start "$PARAMS"
            ;;
        "build")
            npm_build "$PARAMS"
            ;;
        "update")
            npm_update "$PARAMS"
            ;;
        "uninstall")
            npm_uninstall "$PARAMS"
            ;;
        "version")
            npm_version "$PARAMS"
            ;;
        "list")
            npm_list "$PARAMS"
            ;;
        *)
            echo "ERROR: Unknown NPM action - $ACTION"
            return 1
            ;;
    esac
}
```

### Supported Actions

#### `install` - Install dependencies or packages
```bash
npm_install() {
    local PARAMS="$1"
    
    # Extract parameters
    local PACKAGE=$(echo "$PARAMS" | sed -n 's/.*package="\([^"]*\)".*/\1/p')
    local DEV=$(echo "$PARAMS" | sed -n 's/.*dev=\([^,)]*\).*/\1/p')
    local GLOBAL=$(echo "$PARAMS" | sed -n 's/.*global=\([^,)]*\).*/\1/p')
    
    # Build command
    local COMMAND="npm install"
    
    if [ "$GLOBAL" = "true" ]; then
        COMMAND="$COMMAND -g"
    fi
    
    if [ -n "$PACKAGE" ]; then
        if [ "$DEV" = "true" ]; then
            COMMAND="$COMMAND -D"
        fi
        COMMAND="$COMMAND \"$PACKAGE\""
    fi
    
    echo "$COMMAND"
}
```

#### `run_script` - Run package.json script
```bash
npm_run_script() {
    local PARAMS="$1"
    
    # Extract script_name parameter
    local SCRIPT_NAME=$(echo "$PARAMS" | sed -n 's/.*script_name="\([^"]*\)".*/\1/p')
    
    if [ -z "$SCRIPT_NAME" ]; then
        echo "ERROR: script_name parameter required for npm.run_script"
        return 1
    fi
    
    # Validate script exists in package.json
    if [ -f "package.json" ]; then
        if ! grep -q "\"$SCRIPT_NAME\":" package.json; then
            echo "ERROR: Script not found in package.json - $SCRIPT_NAME"
            return 1
        fi
    else
        echo "ERROR: package.json not found"
        return 1
    fi
    
    # Generate command
    echo "npm run \"$SCRIPT_NAME\""
}
```

#### `test` - Run test suite
```bash
npm_test() {
    local PARAMS="$1"
    
    # Extract optional parameters
    local WATCH=$(echo "$PARAMS" | sed -n 's/.*watch=\([^,)]*\).*/\1/p')
    local COVERAGE=$(echo "$PARAMS" | sed -n 's/.*coverage=\([^,)]*\).*/\1/p')
    
    local COMMAND="npm test"
    
    if [ "$WATCH" = "true" ]; then
        COMMAND="$COMMAND -- --watch"
    fi
    
    if [ "$COVERAGE" = "true" ]; then
        COMMAND="$COMMAND -- --coverage"
    fi
    
    echo "$COMMAND"
}
```

#### `init` - Initialize package.json
```bash
npm_init() {
    local PARAMS="$1"
    
    # Extract parameters
    local YES=$(echo "$PARAMS" | sed -n 's/.*yes=\([^,)]*\).*/\1/p')
    
    # Default to yes if not specified
    if [ -z "$YES" ]; then
        YES="true"
    fi
    
    if [ "$YES" = "true" ]; then
        echo "npm init -y"
    else
        echo "npm init"
    fi
}
```

#### `start` - Start application
```bash
npm_start() {
    local PARAMS="$1"
    
    # No parameters needed for start
    echo "npm start"
}
```

#### `build` - Build application
```bash
npm_build() {
    local PARAMS="$1"
    
    # Extract optional parameters
    local PRODUCTION=$(echo "$PARAMS" | sed -n 's/.*production=\([^,)]*\).*/\1/p')
    
    local COMMAND="npm run build"
    
    if [ "$PRODUCTION" = "true" ]; then
        COMMAND="NODE_ENV=production $COMMAND"
    fi
    
    echo "$COMMAND"
}
```

#### `update` - Update packages
```bash
npm_update() {
    local PARAMS="$1"
    
    # Extract parameters
    local PACKAGE=$(echo "$PARAMS" | sed -n 's/.*package="\([^"]*\)".*/\1/p')
    local GLOBAL=$(echo "$PARAMS" | sed -n 's/.*global=\([^,)]*\).*/\1/p')
    
    local COMMAND="npm update"
    
    if [ "$GLOBAL" = "true" ]; then
        COMMAND="$COMMAND -g"
    fi
    
    if [ -n "$PACKAGE" ]; then
        COMMAND="$COMMAND \"$PACKAGE\""
    fi
    
    echo "$COMMAND"
}
```

#### `uninstall` - Remove packages
```bash
npm_uninstall() {
    local PARAMS="$1"
    
    # Extract parameters
    local PACKAGE=$(echo "$PARAMS" | sed -n 's/.*package="\([^"]*\)".*/\1/p')
    local GLOBAL=$(echo "$PARAMS" | sed -n 's/.*global=\([^,)]*\).*/\1/p')
    
    if [ -z "$PACKAGE" ]; then
        echo "ERROR: package parameter required for npm.uninstall"
        return 1
    fi
    
    local COMMAND="npm uninstall"
    
    if [ "$GLOBAL" = "true" ]; then
        COMMAND="$COMMAND -g"
    fi
    
    COMMAND="$COMMAND \"$PACKAGE\""
    
    echo "$COMMAND"
}
```

#### `version` - Show or set version
```bash
npm_version() {
    local PARAMS="$1"
    
    # Extract parameters
    local SHOW=$(echo "$PARAMS" | sed -n 's/.*show=\([^,)]*\).*/\1/p')
    local BUMP=$(echo "$PARAMS" | sed -n 's/.*bump="\([^"]*\)".*/\1/p')
    
    if [ "$SHOW" = "true" ]; then
        echo "npm version"
    elif [ -n "$BUMP" ]; then
        # Validate bump type
        case "$BUMP" in
            "major"|"minor"|"patch")
                echo "npm version $BUMP"
                ;;
            *)
                echo "ERROR: Invalid bump type - $BUMP. Use major, minor, or patch"
                return 1
                ;;
        esac
    else
        echo "npm version"
    fi
}
```

#### `list` - List installed packages
```bash
npm_list() {
    local PARAMS="$1"
    
    # Extract parameters
    local GLOBAL=$(echo "$PARAMS" | sed -n 's/.*global=\([^,)]*\).*/\1/p')
    local DEPTH=$(echo "$PARAMS" | sed -n 's/.*depth=\([^,)]*\).*/\1/p')
    
    local COMMAND="npm list"
    
    if [ "$GLOBAL" = "true" ]; then
        COMMAND="$COMMAND -g"
    fi
    
    if [ -n "$DEPTH" ]; then
        COMMAND="$COMMAND --depth=$DEPTH"
    fi
    
    echo "$COMMAND"
}
```

### Parameter Extraction Helper
```bash
# Helper function to extract parameters from abstract call
extract_npm_param() {
    local PARAMS="$1"
    local PARAM_NAME="$2"
    local DEFAULT_VALUE="$3"
    
    local VALUE=$(echo "$PARAMS" | sed -n "s/.*${PARAM_NAME}=\"\([^\"]*\)\".*/\1/p")
    
    if [ -z "$VALUE" ]; then
        VALUE=$(echo "$PARAMS" | sed -n "s/.*${PARAM_NAME}=\([^,)]*\).*/\1/p")
    fi
    
    if [ -z "$VALUE" ] && [ -n "$DEFAULT_VALUE" ]; then
        VALUE="$DEFAULT_VALUE"
    fi
    
    echo "$VALUE"
}
```

### Validation Functions
```bash
# Validate package.json exists
validate_package_json() {
    if [ ! -f "package.json" ]; then
        echo "ERROR: package.json not found"
        return 1
    fi
    return 0
}

# Validate npm is installed
validate_npm_installed() {
    if ! command -v npm >/dev/null 2>&1; then
        echo "ERROR: npm is not installed"
        return 1
    fi
    return 0
}

# Validate script exists in package.json
validate_script_exists() {
    local SCRIPT_NAME="$1"
    
    if [ ! -f "package.json" ]; then
        echo "ERROR: package.json not found"
        return 1
    fi
    
    if ! grep -q "\"$SCRIPT_NAME\":" package.json; then
        echo "ERROR: Script not found in package.json - $SCRIPT_NAME"
        return 1
    fi
    
    return 0
}

# Validate package name format
validate_package_name() {
    local PACKAGE_NAME="$1"
    
    # Basic validation - package name should not be empty and should not contain spaces
    if [ -z "$PACKAGE_NAME" ]; then
        echo "ERROR: Package name cannot be empty"
        return 1
    fi
    
    if echo "$PACKAGE_NAME" | grep -q " "; then
        echo "ERROR: Package name cannot contain spaces"
        return 1
    fi
    
    return 0
}
```

### Error Handling
- **NPM Installation**: Check if npm is installed and available
- **Package.json Validation**: Ensure package.json exists for relevant operations
- **Script Validation**: Verify scripts exist before running them
- **Package Name Validation**: Check package names are valid
- **Command Generation**: Return proper error codes for invalid operations

### Integration Notes
- Called by `execute_abstract_tool_call.md`
- Returns generated commands as strings
- Handles parameter parsing and validation
- Provides detailed error messages for debugging
- Supports all common NPM operations needed by PRP workflows

### Abstract Call Examples
```bash
# Install all dependencies
npm.install()

# Install specific package
npm.install(package="express")

# Install dev dependency
npm.install(package="nodemon", dev=true)

# Install global package
npm.install(package="typescript", global=true)

# Run script
npm.run_script(script_name="build")

# Run tests
npm.test()

# Run tests with coverage
npm.test(coverage=true)

# Initialize package.json
npm.init(yes=true)

# Start application
npm.start()

# Build for production
npm.build(production=true)

# Update all packages
npm.update()

# Update specific package
npm.update(package="express")

# Uninstall package
npm.uninstall(package="lodash")

# Show version
npm.version(show=true)

# Bump version
npm.version(bump="patch")

# List installed packages
npm.list()

# List global packages
npm.list(global=true)

# List packages with depth
npm.list(depth=0)
```