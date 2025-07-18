#!/bin/bash

# Framework Update Script
# Usage: ./update_project.sh /path/to/your/project

PROJECT_PATH="${1:-}"
FRAMEWORK_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$PROJECT_PATH" ]; then
    echo "❌ Error: Please provide project path"
    echo "Usage: $0 /path/to/your/project"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project directory does not exist: $PROJECT_PATH"
    exit 1
fi

echo "🔄 Updating AI Framework"
echo "Source: $FRAMEWORK_SOURCE"
echo "Target: $PROJECT_PATH"
echo ""

# Backup existing framework
if [ -d "$PROJECT_PATH/.ai_workflow" ]; then
    echo "📦 Backing up existing framework..."
    cp -r "$PROJECT_PATH/.ai_workflow" "$PROJECT_PATH/.ai_workflow.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Copy updated framework
echo "📥 Copying updated framework..."
cp -r "$FRAMEWORK_SOURCE/.ai_workflow" "$PROJECT_PATH/"

# Update ai-dev script
echo "🔧 Updating ai-dev script..."
cp "$FRAMEWORK_SOURCE/ai-dev" "$PROJECT_PATH/"
chmod +x "$PROJECT_PATH/ai-dev"

# Preserve project-specific configs
if [ -f "$PROJECT_PATH/.ai_workflow.backup.*/config/project_config.json" ]; then
    echo "💾 Preserving project configuration..."
    cp "$PROJECT_PATH/.ai_workflow.backup.*/config/project_config.json" "$PROJECT_PATH/.ai_workflow/config/" 2>/dev/null || true
fi

echo ""
echo "✅ Framework updated successfully!"
echo "🧪 Test with: cd $PROJECT_PATH && ./ai-dev status"