---
description: Executable workflow for generating Product Requirement Prompts (PRPs) from a Product Requirements Document (PRD).
globs:
  alwaysApply: false
---
# Workflow: Generate PRPs from PRD

## Goal

Generate one or more detailed, executable **Product Requirement Prompts (PRPs)** in Markdown format from an existing Product Requirements Document (PRD). Each PRP will be a self-contained, actionable plan using the abstract tool-based engine.

## Commands

```bash
# 1. Validate PRD file exists
if [[ -z "$PRD_FILE_PATH" ]]; then
    echo "❌ PRD_FILE_PATH environment variable not set"
    exit 1
fi

if [[ ! -f "$PRD_FILE_PATH" ]]; then
    echo "❌ PRD file not found: $PRD_FILE_PATH"
    exit 1
fi

echo "📋 Found PRD file: $PRD_FILE_PATH"

# 2. Setup logging
mkdir -p .ai_workflow/logs
GENERATE_LOG=".ai_workflow/logs/generate_$(date +%Y%m%d_%H%M%S).log"
echo "[START] Generating PRPs from: $PRD_FILE_PATH at $(date)" > "$GENERATE_LOG"

# 3. Execute PRP generation using the executable script
if [[ -f ".ai_workflow/scripts/generate_prps.sh" ]]; then
    echo "🔧 Using PRP generator script..."
    bash .ai_workflow/scripts/generate_prps.sh "$PRD_FILE_PATH"
    GENERATOR_EXIT_CODE=$?
    
    if [[ $GENERATOR_EXIT_CODE -eq 0 ]]; then
        echo "✅ PRP generation completed successfully"
        
        # Show generated files to user
        echo ""
        echo "🎉 PRPs generated successfully!"
        echo "📁 Location: .ai_workflow/PRPs/generated/"
        echo ""
        echo "Generated files:"
        ls -la .ai_workflow/PRPs/generated/prp-*.md 2>/dev/null | while read -r line; do
            echo "   - $(basename "$(echo "$line" | awk '{print $NF}')")"
        done
        echo ""
        echo "💡 Next steps:"
        echo "   - Review the generated PRPs"
        echo "   - Execute them with: ./ai-dev run <prp-file>"
        echo "   - Modify PRPs as needed for your requirements"
        
    else
        echo "❌ PRP generation failed with exit code: $GENERATOR_EXIT_CODE"
        exit $GENERATOR_EXIT_CODE
    fi
else
    echo "❌ PRP generator script not found: .ai_workflow/scripts/generate_prps.sh"
    echo "   This is a framework installation issue."
    exit 1
fi

echo "[END] PRP generation finished at $(date)" >> "$GENERATE_LOG"
```

## Verification Criteria
- PRD file must exist and be readable
- PRP generator script must be available
- Generated PRPs must be saved to .ai_workflow/PRPs/generated/
- Each generated PRP must follow the proper template structure

## Output
- Multiple PRP files in .ai_workflow/PRPs/generated/
- Generation log in .ai_workflow/logs/
- User feedback about generated files and next steps

