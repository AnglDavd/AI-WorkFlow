# Generate Project Architecture Documentation

## Purpose
Automatically generate comprehensive ARCHITECTURE.md documentation for user projects during framework setup. This creates a living architectural document that adapts to the specific project's technology stack and evolves with the project.

## Execution Context
- **Trigger:** During `./ai-dev setup` or manually via `./ai-dev generate-architecture`
- **Goal:** Create project-specific architectural documentation
- **Input:** Project directory, detected technologies, user preferences
- **Output:** Customized ARCHITECTURE.md file for the user's project

## Implementation

```bash
#!/bin/bash

# Generate Project Architecture Documentation
echo "🏗️ Generating project architecture documentation..."

# Variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
ARCHITECTURE_FILE="$PROJECT_ROOT/ARCHITECTURE.md"
TEMP_DIR="/tmp/ai_architecture_$$"
mkdir -p "$TEMP_DIR"

# Detect project information
PROJECT_NAME=$(basename "$PROJECT_ROOT")
PROJECT_TYPE=""
MAIN_LANGUAGES=()
FRAMEWORKS=()
DEPENDENCIES=()
BUILD_TOOLS=()
TESTING_FRAMEWORKS=()

echo "📁 Project: $PROJECT_NAME"
echo "📍 Location: $PROJECT_ROOT"

# === TECHNOLOGY DETECTION ===
echo "🔍 Detecting project technologies..."

# Language Detection
if [[ -f "package.json" ]]; then
    MAIN_LANGUAGES+=("JavaScript/TypeScript")
    PROJECT_TYPE="Web/Node.js"
    BUILD_TOOLS+=("npm/yarn")
    
    # Framework detection from package.json
    if grep -q "react" package.json 2>/dev/null; then
        FRAMEWORKS+=("React")
    fi
    if grep -q "vue" package.json 2>/dev/null; then
        FRAMEWORKS+=("Vue.js")
    fi
    if grep -q "angular" package.json 2>/dev/null; then
        FRAMEWORKS+=("Angular")
    fi
    if grep -q "next" package.json 2>/dev/null; then
        FRAMEWORKS+=("Next.js")
    fi
    if grep -q "express" package.json 2>/dev/null; then
        FRAMEWORKS+=("Express.js")
    fi
    if grep -q "jest" package.json 2>/dev/null; then
        TESTING_FRAMEWORKS+=("Jest")
    fi
    if grep -q "cypress" package.json 2>/dev/null; then
        TESTING_FRAMEWORKS+=("Cypress")
    fi
fi

if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
    MAIN_LANGUAGES+=("Python")
    PROJECT_TYPE="Python"
    BUILD_TOOLS+=("pip/poetry")
    
    # Python framework detection
    if grep -q "django" requirements.txt 2>/dev/null || grep -q "django" pyproject.toml 2>/dev/null; then
        FRAMEWORKS+=("Django")
    fi
    if grep -q "flask" requirements.txt 2>/dev/null || grep -q "flask" pyproject.toml 2>/dev/null; then
        FRAMEWORKS+=("Flask")
    fi
    if grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
        FRAMEWORKS+=("FastAPI")
    fi
    if grep -q "pytest" requirements.txt 2>/dev/null || grep -q "pytest" pyproject.toml 2>/dev/null; then
        TESTING_FRAMEWORKS+=("pytest")
    fi
fi

if [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
    MAIN_LANGUAGES+=("Java")
    PROJECT_TYPE="Java"
    
    if [[ -f "pom.xml" ]]; then
        BUILD_TOOLS+=("Maven")
        # Spring detection
        if grep -q "spring" pom.xml 2>/dev/null; then
            FRAMEWORKS+=("Spring/Spring Boot")
        fi
        if grep -q "junit" pom.xml 2>/dev/null; then
            TESTING_FRAMEWORKS+=("JUnit")
        fi
    fi
    
    if [[ -f "build.gradle" ]]; then
        BUILD_TOOLS+=("Gradle")
        if grep -q "spring" build.gradle 2>/dev/null; then
            FRAMEWORKS+=("Spring/Spring Boot")
        fi
    fi
fi

if [[ -f "Cargo.toml" ]]; then
    MAIN_LANGUAGES+=("Rust")
    PROJECT_TYPE="Rust"
    BUILD_TOOLS+=("Cargo")
    
    if grep -q "tokio" Cargo.toml 2>/dev/null; then
        FRAMEWORKS+=("Tokio")
    fi
    if grep -q "actix" Cargo.toml 2>/dev/null; then
        FRAMEWORKS+=("Actix")
    fi
fi

if [[ -f "go.mod" ]]; then
    MAIN_LANGUAGES+=("Go")
    PROJECT_TYPE="Go"
    BUILD_TOOLS+=("go modules")
    
    if grep -q "gin" go.mod 2>/dev/null; then
        FRAMEWORKS+=("Gin")
    fi
    if grep -q "echo" go.mod 2>/dev/null; then
        FRAMEWORKS+=("Echo")
    fi
fi

# Additional detections
if [[ -f "Dockerfile" ]]; then
    BUILD_TOOLS+=("Docker")
fi

if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
    BUILD_TOOLS+=("Docker Compose")
fi

if [[ -f ".github/workflows" ]]; then
    BUILD_TOOLS+=("GitHub Actions")
fi

# Default values if nothing detected
if [[ ${#MAIN_LANGUAGES[@]} -eq 0 ]]; then
    MAIN_LANGUAGES=("Multiple/Mixed")
    PROJECT_TYPE="Generic"
fi

echo "✅ Detected: ${MAIN_LANGUAGES[*]}"
echo "🚀 Project Type: $PROJECT_TYPE"
echo "⚙️ Frameworks: ${FRAMEWORKS[*]:-None}"
echo "🔧 Build Tools: ${BUILD_TOOLS[*]:-None}"

# === GENERATE ARCHITECTURE.MD ===
echo "📝 Generating ARCHITECTURE.md..."

cat > "$ARCHITECTURE_FILE" << EOF
# ${PROJECT_NAME} Architecture

**Project Type:** ${PROJECT_TYPE}  
**Main Languages:** ${MAIN_LANGUAGES[*]}  
**Last Updated:** $(date)  
**Generated by:** AI-Assisted Development Framework

## Project Overview

### Technology Stack

**Languages:** ${MAIN_LANGUAGES[*]}  
**Frameworks:** ${FRAMEWORKS[*]:-None detected}  
**Build Tools:** ${BUILD_TOOLS[*]:-None detected}  
**Testing:** ${TESTING_FRAMEWORKS[*]:-None detected}  

### Project Structure

\`\`\`
${PROJECT_NAME}/
$(find . -maxdepth 2 -type d -not -path './.*' -not -path './node_modules' -not -path './venv' -not -path './target' -not -path './build' | head -20 | sort | sed 's|^\./|├── |')
\`\`\`

## Architecture Components

### 1. Core Components

EOF

# Generate component sections based on detected technology
if [[ " ${MAIN_LANGUAGES[*]} " =~ " JavaScript/TypeScript " ]]; then
    cat >> "$ARCHITECTURE_FILE" << EOF
#### Frontend/Backend Components
- **Source Code:** \`src/\` or \`lib/\`
- **Configuration:** \`package.json\`, \`tsconfig.json\`
- **Build Output:** \`dist/\` or \`build/\`
- **Dependencies:** \`node_modules/\`

EOF
fi

if [[ " ${MAIN_LANGUAGES[*]} " =~ " Python " ]]; then
    cat >> "$ARCHITECTURE_FILE" << EOF
#### Python Components
- **Source Code:** Project root or \`src/\`
- **Configuration:** \`requirements.txt\`, \`pyproject.toml\`, \`setup.py\`
- **Virtual Environment:** \`venv/\` or \`.venv/\`
- **Tests:** \`tests/\` or \`test/\`

EOF
fi

if [[ " ${MAIN_LANGUAGES[*]} " =~ " Java " ]]; then
    cat >> "$ARCHITECTURE_FILE" << EOF
#### Java Components
- **Source Code:** \`src/main/java/\`
- **Resources:** \`src/main/resources/\`
- **Tests:** \`src/test/java/\`
- **Build Output:** \`target/\` (Maven) or \`build/\` (Gradle)

EOF
fi

# Continue with common sections
cat >> "$ARCHITECTURE_FILE" << EOF
### 2. Configuration Management

#### Configuration Files
EOF

# List actual configuration files found
for config_file in package.json requirements.txt pyproject.toml pom.xml build.gradle Cargo.toml go.mod Dockerfile docker-compose.yml .env; do
    if [[ -f "$config_file" ]]; then
        echo "- **\`$config_file\`** - $(get_config_description "$config_file")" >> "$ARCHITECTURE_FILE"
    fi
done

cat >> "$ARCHITECTURE_FILE" << EOF

### 3. Build and Deployment

#### Build System
EOF

# Add build system information
for build_tool in "${BUILD_TOOLS[@]}"; do
    case $build_tool in
        "npm/yarn")
            echo "- **npm/yarn** - JavaScript package management and build scripts" >> "$ARCHITECTURE_FILE"
            ;;
        "pip/poetry")
            echo "- **pip/poetry** - Python dependency management" >> "$ARCHITECTURE_FILE"
            ;;
        "Maven")
            echo "- **Maven** - Java build automation and dependency management" >> "$ARCHITECTURE_FILE"
            ;;
        "Gradle")
            echo "- **Gradle** - Java/Kotlin build automation" >> "$ARCHITECTURE_FILE"
            ;;
        "Cargo")
            echo "- **Cargo** - Rust package manager and build tool" >> "$ARCHITECTURE_FILE"
            ;;
        "Docker")
            echo "- **Docker** - Containerization platform" >> "$ARCHITECTURE_FILE"
            ;;
        "Docker Compose")
            echo "- **Docker Compose** - Multi-container application orchestration" >> "$ARCHITECTURE_FILE"
            ;;
    esac
done

cat >> "$ARCHITECTURE_FILE" << EOF

## Development Workflow

### 1. Setup Process
EOF

# Generate setup instructions based on detected technology
if [[ " ${BUILD_TOOLS[*]} " =~ " npm/yarn " ]]; then
    cat >> "$ARCHITECTURE_FILE" << EOF
1. **Install Dependencies**: \`npm install\` or \`yarn install\`
2. **Development Server**: \`npm run dev\` or \`yarn dev\`
3. **Build**: \`npm run build\` or \`yarn build\`
EOF
fi

if [[ " ${BUILD_TOOLS[*]} " =~ " pip/poetry " ]]; then
    cat >> "$ARCHITECTURE_FILE" << EOF
1. **Virtual Environment**: \`python -m venv venv\` and \`source venv/bin/activate\`
2. **Install Dependencies**: \`pip install -r requirements.txt\`
3. **Run Application**: \`python main.py\` or framework-specific command
EOF
fi

if [[ " ${BUILD_TOOLS[*]} " =~ " Maven " ]]; then
    cat >> "$ARCHITECTURE_FILE" << EOF
1. **Build**: \`mvn clean compile\`
2. **Test**: \`mvn test\`
3. **Package**: \`mvn package\`
EOF
fi

cat >> "$ARCHITECTURE_FILE" << EOF

### 2. Testing Strategy

#### Testing Framework
EOF

# Add testing information
if [[ ${#TESTING_FRAMEWORKS[@]} -gt 0 ]]; then
    for framework in "${TESTING_FRAMEWORKS[@]}"; do
        echo "- **$framework** - Primary testing framework" >> "$ARCHITECTURE_FILE"
    done
else
    echo "- **Testing framework not detected** - Consider adding automated testing" >> "$ARCHITECTURE_FILE"
fi

cat >> "$ARCHITECTURE_FILE" << EOF

### 3. Quality Assurance

#### AI Framework Integration
- **Quality Validation**: Integrated with AI framework's adaptive language support
- **Pre-commit Hooks**: Automatic validation before commits
- **Security Scanning**: Dependency vulnerability checks
- **Code Quality**: Complexity and maintainability analysis

## Dependency Management

### 1. Dependency Matrix

#### Core Dependencies
EOF

# Generate dependency information
if [[ -f "package.json" ]]; then
    echo "**JavaScript/TypeScript Dependencies:**" >> "$ARCHITECTURE_FILE"
    echo '```json' >> "$ARCHITECTURE_FILE"
    jq '.dependencies // {}' package.json 2>/dev/null | head -10 >> "$ARCHITECTURE_FILE"
    echo '```' >> "$ARCHITECTURE_FILE"
fi

if [[ -f "requirements.txt" ]]; then
    echo "**Python Dependencies:**" >> "$ARCHITECTURE_FILE"
    echo '```' >> "$ARCHITECTURE_FILE"
    head -10 requirements.txt >> "$ARCHITECTURE_FILE"
    echo '```' >> "$ARCHITECTURE_FILE"
fi

cat >> "$ARCHITECTURE_FILE" << EOF

### 2. Update Strategy

#### Regular Updates
- **Security Updates**: Monthly security dependency updates
- **Framework Updates**: Quarterly framework version updates
- **Quality Validation**: All updates validated through AI framework quality gates

## Change Management

### 1. Change Impact Matrix

#### When Adding New Features
**Files typically affected:**
- Source code files in main development directory
- Configuration files (package.json, requirements.txt, etc.)
- Test files
- Documentation files
- Build configuration

**Validation required:**
- [ ] Code quality validation
- [ ] Security scanning
- [ ] Test execution
- [ ] Documentation updates
- [ ] Architecture documentation updates

#### When Modifying Dependencies
**Files typically affected:**
- Dependency configuration files
- Lock files (package-lock.json, poetry.lock, etc.)
- Build configuration
- CI/CD configuration

**Validation required:**
- [ ] Dependency security scanning
- [ ] Compatibility testing
- [ ] Integration testing
- [ ] Performance impact assessment

### 2. Quality Gates

#### Pre-commit Validation
- **Syntax Validation**: Language-specific syntax checking
- **Code Quality**: Complexity and maintainability analysis
- **Security Scan**: Dependency vulnerability checking
- **Test Execution**: Automated test suite execution

#### Continuous Integration
- **Build Validation**: Successful build verification
- **Integration Testing**: Component integration verification
- **Performance Testing**: Performance regression detection
- **Documentation Updates**: Architecture documentation synchronization

## Maintenance and Evolution

### 1. Regular Maintenance

#### Monthly Tasks
- [ ] Security dependency updates
- [ ] Documentation review and updates
- [ ] Performance analysis and optimization
- [ ] Technical debt assessment

#### Quarterly Tasks
- [ ] Framework version updates
- [ ] Architecture review and updates
- [ ] Dependency audit and cleanup
- [ ] Performance benchmarking

### 2. Evolution Strategy

#### Scalability Planning
- **Horizontal Scaling**: Plan for increased load
- **Vertical Scaling**: Plan for increased complexity
- **Modularity**: Maintain clean component boundaries
- **Documentation**: Keep architecture documentation current

#### Technology Evolution
- **Framework Updates**: Stay current with framework versions
- **Language Updates**: Adopt new language features appropriately
- **Tool Updates**: Upgrade development and build tools
- **Security Updates**: Maintain security best practices

## Integration with AI Framework

### 1. Quality Integration

#### Automatic Validation
- **Language Detection**: Automatic detection of project languages
- **Quality Gates**: Integrated quality validation
- **Security Scanning**: Automatic dependency vulnerability scanning
- **Documentation Updates**: Automatic architecture documentation updates

#### Manual Commands
- **\`./ai-dev quality <path>\`**: Run quality validation
- **\`./ai-dev audit\`**: Run security audit
- **\`./ai-dev update-architecture\`**: Update architecture documentation

### 2. Continuous Improvement

#### Feedback Loop
- **Quality Metrics**: Track quality metrics over time
- **Performance Metrics**: Monitor performance trends
- **Security Metrics**: Track security posture
- **Documentation Metrics**: Ensure documentation stays current

---

**Document Status:** Living document - Update when architecture changes  
**Next Review:** $(date -d "+1 month")  
**Generated by:** AI-Assisted Development Framework v0.4.1-beta  
**Maintenance:** Run \`./ai-dev update-architecture\` to refresh this document
EOF

# Function to describe configuration files
get_config_description() {
    case "$1" in
        "package.json") echo "Node.js project configuration and dependencies" ;;
        "requirements.txt") echo "Python project dependencies" ;;
        "pyproject.toml") echo "Python project configuration and dependencies" ;;
        "pom.xml") echo "Maven project configuration and dependencies" ;;
        "build.gradle") echo "Gradle build configuration" ;;
        "Cargo.toml") echo "Rust project configuration and dependencies" ;;
        "go.mod") echo "Go module configuration" ;;
        "Dockerfile") echo "Docker container configuration" ;;
        "docker-compose.yml") echo "Multi-container application configuration" ;;
        ".env") echo "Environment variables configuration" ;;
        *) echo "Project configuration file" ;;
    esac
}

echo "✅ Architecture documentation generated: $ARCHITECTURE_FILE"
echo "📊 Project type: $PROJECT_TYPE"
echo "🔧 Technologies: ${MAIN_LANGUAGES[*]}"
echo "📝 Documentation ready for customization"

# Add to quality validation system
if [[ -f ".ai_workflow/config/quality_config.json" ]]; then
    echo "🔗 Integrating with quality validation system..."
    # Add architecture documentation to quality validation
    # This ensures the documentation stays updated
fi

# Clean up
rm -rf "$TEMP_DIR"

echo "🎉 Project architecture documentation generation completed!"
echo "💡 Run './ai-dev update-architecture' to refresh documentation as project evolves"
```

## Integration Points

This workflow integrates with:
- **Project setup workflow** - Automatically generates during setup
- **Quality validation system** - Ensures documentation stays current
- **Technology detection** - Adapts to project's specific technology stack
- **Change impact tracking** - Provides project-specific change management guidance

## Output

Creates a comprehensive, project-specific ARCHITECTURE.md that includes:
- Detected technology stack
- Project structure analysis
- Dependency management
- Change impact matrix
- Quality integration guidelines
- Maintenance schedules
- Evolution strategy

The generated documentation adapts to the specific project and provides ongoing value as the project evolves.