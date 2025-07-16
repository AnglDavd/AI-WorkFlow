#!/bin/bash

# Quality configuration management script
CONFIG_FILE=".ai_workflow/config/quality_config.json"

get_config() {
    local key="$1"
    jq -r "$key" "$CONFIG_FILE" 2>/dev/null || echo "true"
}

set_config() {
    local key="$1"
    local value="$2"
    
    # Create backup
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    
    # Update configuration
    jq "$key = $value" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

# Load configuration into environment
load_quality_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        export QUALITY_VALIDATION_ENABLED=$(get_config '.quality_validation.enabled')
        export QUALITY_VALIDATION_STRICT=$(get_config '.quality_validation.strict_mode')
        export LANGUAGE_DETECTION_ENABLED=$(get_config '.language_detection.enabled')
        export AUTO_CONFIGURE_TOOLS=$(get_config '.language_detection.auto_configure_tools')
    else
        # Default values
        export QUALITY_VALIDATION_ENABLED="true"
        export QUALITY_VALIDATION_STRICT="false"
        export LANGUAGE_DETECTION_ENABLED="true"
        export AUTO_CONFIGURE_TOOLS="true"
    fi
}

# Usage examples:
# load_quality_config
# set_config '.quality_validation.enabled' 'false'
# get_config '.quality_validation.strict_mode'
