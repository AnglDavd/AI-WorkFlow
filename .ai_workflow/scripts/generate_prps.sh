#!/bin/bash
# PRP Generator - Creates executable PRPs from PRD files
set -euo pipefail

generate_prps_from_prd() {
    local prd_file="$1"
    
    if [[ ! -f "$prd_file" ]]; then
        echo "❌ PRD file not found: $prd_file"
        return 1
    fi
    
    echo "📋 Analyzing PRD file: $prd_file"
    
    # Create output directory
    mkdir -p .ai_workflow/PRPs/generated
    
    # Extract simple project name
    local project_name="project"
    if [[ -f "$prd_file" ]]; then
        local first_line
        first_line=$(head -n1 "$prd_file")
        # Simple extraction of first word after #
        project_name=$(echo "$first_line" | sed 's/^#[[:space:]]*//' | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        if [[ -z "$project_name" ]]; then
            project_name="project"
        fi
    fi
    
    echo "🏗️  Project identified: $project_name"
    
    # Generate frontend PRP
    local frontend_prp=".ai_workflow/PRPs/generated/prp-${project_name}-frontend.md"
    echo "🎨 Generating frontend PRP: $frontend_prp"
    
    cat > "$frontend_prp" << EOF
# PRP: ${project_name^} Frontend Interface

## Goal
Create a modern, responsive frontend interface for the ${project_name^} application.

## Why
- Primary user interaction point
- Must be intuitive and responsive
- Supports business operations efficiently

## What
A web-based frontend interface with:
- Responsive design for desktop and mobile
- User-friendly navigation
- Interactive components
- Modern styling and UX

## Implementation Plan

### Task 1: Create HTML Structure
**Actions:**
- WRITE_FILE: \`src/index.html\` - Create main application HTML with semantic structure
- WRITE_FILE: \`src/components/header.html\` - Create reusable header component
- WRITE_FILE: \`src/components/footer.html\` - Create reusable footer component

**Validations:**
- FILE_EXISTS: \`src/index.html\`
- FILE_EXISTS: \`src/components/header.html\`
- RUN_TESTS: HTML validation tests

### Task 2: Implement CSS Styling
**Actions:**
- WRITE_FILE: \`src/styles/main.css\` - Create main stylesheet with responsive design
- WRITE_FILE: \`src/styles/components.css\` - Create component-specific styles

**Validations:**
- FILE_EXISTS: \`src/styles/main.css\`
- LINT_FILE: \`src/styles/main.css\`

### Task 3: Add JavaScript Functionality
**Actions:**
- WRITE_FILE: \`src/js/main.js\` - Create main application JavaScript
- WRITE_FILE: \`src/js/components.js\` - Create component interaction logic

**Validations:**
- FILE_EXISTS: \`src/js/main.js\`
- LINT_FILE: \`src/js/main.js\`
- RUN_TESTS: JavaScript functionality tests

## Success Criteria
- Responsive design works on all target devices
- Interactive components function correctly
- Clean, maintainable code structure
EOF

    echo "   ✅ Frontend PRP created"
    
    # Generate setup PRP
    local setup_prp=".ai_workflow/PRPs/generated/prp-${project_name}-setup.md"
    echo "⚙️  Generating setup PRP: $setup_prp"
    
    cat > "$setup_prp" << EOF
# PRP: ${project_name^} Project Setup

## Goal
Setup and configure the ${project_name^} project infrastructure.

## Why
- Project foundation needs establishment
- Development environment configuration required
- Build and deployment systems needed

## What
A complete project setup with:
- Project structure and organization
- Build and development tools
- Documentation framework

## Implementation Plan

### Task 1: Create Project Structure
**Actions:**
- WRITE_FILE: \`package.json\` - Create project configuration with dependencies
- WRITE_FILE: \`README.md\` - Create project documentation and setup instructions
- WRITE_FILE: \`.gitignore\` - Create git ignore rules for project

**Validations:**
- FILE_EXISTS: \`package.json\`
- FILE_EXISTS: \`README.md\`

### Task 2: Setup Development Tools
**Actions:**
- WRITE_FILE: \`webpack.config.js\` - Create build configuration
- WRITE_FILE: \`.eslintrc.js\` - Create code quality configuration

**Validations:**
- FILE_EXISTS: \`webpack.config.js\`
- RUN_TESTS: build system tests

## Success Criteria
- Project builds successfully
- Development environment is functional
- Documentation is complete and accurate
EOF

    echo "   ✅ Setup PRP created"
    
    echo "✅ Generated 2 PRP files in .ai_workflow/PRPs/generated/"
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <prd_file>"
        exit 1
    fi
    
    generate_prps_from_prd "$1"
fi