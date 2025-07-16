#!/bin/bash

# Quality validation environment setup
echo "🔧 Setting up quality validation environment..."

# Source configuration
if [[ -f ".ai_workflow/config/manage_quality_config.sh" ]]; then
    source .ai_workflow/config/manage_quality_config.sh
    load_quality_config
else
    # Default environment
    export QUALITY_VALIDATION_ENABLED="true"
    export QUALITY_VALIDATION_STRICT="false"
    export LANGUAGE_DETECTION_ENABLED="true"
    export AUTO_CONFIGURE_TOOLS="true"
fi

# Create cache directories
mkdir -p .ai_workflow/cache/quality
mkdir -p .ai_workflow/cache/language_support

# Set up git hooks if not already done
if [[ -f ".ai_workflow/precommit/hooks/pre-commit" ]]; then
    # Install git hooks
    if [[ -d ".git/hooks" ]]; then
        ln -sf "../../.ai_workflow/precommit/hooks/pre-commit" ".git/hooks/pre-commit"
        chmod +x ".git/hooks/pre-commit"
        echo "✅ Git hooks installed"
    fi
fi

echo "✅ Quality validation environment ready"
echo "   - Quality validation: $QUALITY_VALIDATION_ENABLED"
echo "   - Strict mode: $QUALITY_VALIDATION_STRICT"
echo "   - Language detection: $LANGUAGE_DETECTION_ENABLED"
echo "   - Auto-configure tools: $AUTO_CONFIGURE_TOOLS"
