# Adaptive Language Support Workflow

## Purpose
Provide graceful degradation and automatic language support extension for projects using languages not explicitly supported by the framework, with minimal user intervention.

## Design Philosophy
- **Zero-Friction Extension**: Automatically detect and adapt to new languages
- **PRD Integration**: Leverage language information from PRD creation phase
- **Intelligent Fallbacks**: Provide meaningful analysis even for unknown languages
- **Self-Learning**: Framework learns from user projects to improve future support

## Input Parameters
- `PROJECT_PATH`: Path to project directory (default: current directory)
- `LANGUAGE_HINT`: Language hint from PRD or user input (optional)
- `AUTO_CONFIGURE`: Enable automatic tool configuration (default: true)
- `SAVE_PROFILE`: Save language profile for future projects (default: true)

## Workflow Steps

### 1. Load Language Configuration
```bash
# Set default values
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
AUTO_CONFIGURE="${AUTO_CONFIGURE:-true}"
SAVE_PROFILE="${SAVE_PROFILE:-true}"

# Create language support directory
LANG_SUPPORT_DIR=".ai_workflow/config/language_support"
mkdir -p "$LANG_SUPPORT_DIR"

# Load existing language profiles
CUSTOM_LANGS_FILE="$LANG_SUPPORT_DIR/custom_languages.json"
if [[ ! -f "$CUSTOM_LANGS_FILE" ]]; then
    echo '{
      "languages": {},
      "detection_patterns": {},
      "tool_mappings": {},
      "last_updated": "'$(date -Iseconds)'"
    }' > "$CUSTOM_LANGS_FILE"
fi

# Load PRD language information if available
PRD_LANG_INFO=""
if [[ -f ".ai_workflow/PRPs/current_prd.md" ]]; then
    PRD_LANG_INFO=$(grep -i "programming language\|technology stack\|language:" ".ai_workflow/PRPs/current_prd.md" | head -5)
fi
```

### 2. Enhanced Language Detection
```bash
echo "=== Enhanced Language Detection ==="

# Extended language detection patterns
declare -A EXTENDED_LANG_PATTERNS=(
  # Core languages (existing)
  ["javascript"]="*.js *.jsx *.mjs *.cjs *.es6"
  ["typescript"]="*.ts *.tsx *.d.ts"
  ["python"]="*.py *.pyx *.pyi *.pyw"
  ["java"]="*.java *.class *.jar"
  ["go"]="*.go"
  ["rust"]="*.rs"
  ["cpp"]="*.cpp *.cxx *.cc *.c++ *.hpp *.hxx *.hh *.h++"
  ["c"]="*.c *.h"
  ["csharp"]="*.cs *.csx *.vb"
  
  # Extended languages
  ["kotlin"]="*.kt *.kts"
  ["scala"]="*.scala *.sc"
  ["swift"]="*.swift"
  ["dart"]="*.dart"
  ["elixir"]="*.ex *.exs"
  ["clojure"]="*.clj *.cljs *.cljc *.edn"
  ["haskell"]="*.hs *.lhs"
  ["lua"]="*.lua"
  ["perl"]="*.pl *.pm *.t"
  ["r"]="*.r *.R *.Rmd"
  ["matlab"]="*.m *.mlx"
  ["julia"]="*.jl"
  ["erlang"]="*.erl *.hrl"
  ["fsharp"]="*.fs *.fsi *.fsx"
  ["ocaml"]="*.ml *.mli"
  ["nim"]="*.nim"
  ["crystal"]="*.cr"
  ["zig"]="*.zig"
  ["solidity"]="*.sol"
  ["vue"]="*.vue"
  ["svelte"]="*.svelte"
  ["shell"]="*.sh *.bash *.zsh *.fish"
  ["powershell"]="*.ps1 *.psm1"
  ["yaml"]="*.yml *.yaml"
  ["toml"]="*.toml"
  ["json"]="*.json *.jsonc"
  ["xml"]="*.xml *.xsd *.xsl"
  ["html"]="*.html *.htm *.xhtml"
  ["css"]="*.css *.scss *.sass *.less"
  ["dockerfile"]="Dockerfile* *.dockerfile"
  ["makefile"]="Makefile* *.mk"
  ["cmake"]="CMakeLists.txt *.cmake"
  ["protobuf"]="*.proto"
  ["graphql"]="*.graphql *.gql"
  ["sql"]="*.sql *.ddl *.dml"
)

# Load custom language patterns
if [[ -f "$CUSTOM_LANGS_FILE" ]]; then
    # Merge custom patterns with built-in patterns
    while IFS= read -r lang; do
        if [[ -n "$lang" ]]; then
            patterns=$(jq -r ".languages[\"$lang\"].patterns[]?" "$CUSTOM_LANGS_FILE" 2>/dev/null | tr '\n' ' ')
            if [[ -n "$patterns" ]]; then
                EXTENDED_LANG_PATTERNS["$lang"]="$patterns"
            fi
        fi
    done < <(jq -r '.languages | keys[]?' "$CUSTOM_LANGS_FILE" 2>/dev/null)
fi

# Perform enhanced detection
declare -A LANGUAGE_SCORES
for lang in "${!EXTENDED_LANG_PATTERNS[@]}"; do
    count=0
    for pattern in ${EXTENDED_LANG_PATTERNS[$lang]}; do
        files=$(find "$PROJECT_PATH" -name "$pattern" -type f 2>/dev/null | wc -l)
        count=$((count + files))
    done
    LANGUAGE_SCORES[$lang]=$count
done

# Find primary and secondary languages
PRIMARY_LANG="unknown"
SECONDARY_LANGS=()
MAX_COUNT=0

for lang in "${!LANGUAGE_SCORES[@]}"; do
    count=${LANGUAGE_SCORES[$lang]}
    if [[ $count -gt $MAX_COUNT ]]; then
        if [[ "$PRIMARY_LANG" != "unknown" ]]; then
            SECONDARY_LANGS+=("$PRIMARY_LANG")
        fi
        MAX_COUNT=$count
        PRIMARY_LANG=$lang
    elif [[ $count -gt 5 ]]; then
        SECONDARY_LANGS+=("$lang")
    fi
done

echo "Detected primary language: $PRIMARY_LANG ($MAX_COUNT files)"
echo "Secondary languages: ${SECONDARY_LANGS[*]}"
```

### 3. PRD Language Information Integration
```bash
echo "=== Integrating PRD Language Information ==="

# Extract language information from PRD
if [[ -n "$PRD_LANG_INFO" ]]; then
    echo "Found PRD language information:"
    echo "$PRD_LANG_INFO"
    
    # Parse common language mentions
    PRD_MENTIONED_LANGS=()
    
    # Check for specific language mentions
    for lang in "${!EXTENDED_LANG_PATTERNS[@]}"; do
        if echo "$PRD_LANG_INFO" | grep -qi "$lang"; then
            PRD_MENTIONED_LANGS+=("$lang")
        fi
    done
    
    # Override detection if PRD is more specific
    if [[ ${#PRD_MENTIONED_LANGS[@]} -gt 0 ]]; then
        echo "PRD mentions languages: ${PRD_MENTIONED_LANGS[*]}"
        
        # If PRD mentions languages not detected, add them
        for prd_lang in "${PRD_MENTIONED_LANGS[@]}"; do
            if [[ "$prd_lang" != "$PRIMARY_LANG" ]]; then
                SECONDARY_LANGS+=("$prd_lang")
            fi
        done
        
        # If no files detected but PRD mentions a language, use PRD info
        if [[ "$PRIMARY_LANG" == "unknown" && ${#PRD_MENTIONED_LANGS[@]} -gt 0 ]]; then
            PRIMARY_LANG="${PRD_MENTIONED_LANGS[0]}"
            echo "Using PRD-specified primary language: $PRIMARY_LANG"
        fi
    fi
fi

# Use language hint if provided
if [[ -n "$LANGUAGE_HINT" ]]; then
    echo "Using provided language hint: $LANGUAGE_HINT"
    PRIMARY_LANG="$LANGUAGE_HINT"
fi
```

### 4. Automatic Tool Configuration
```bash
echo "=== Automatic Tool Configuration ==="

# Default tool configurations for extended languages
declare -A DEFAULT_TOOLS=(
  # Core languages
  ["javascript"]='{"linting": ["eslint", "jshint"], "testing": ["jest", "mocha"], "formatting": ["prettier"]}'
  ["typescript"]='{"linting": ["eslint", "@typescript-eslint/eslint-plugin"], "testing": ["jest"], "formatting": ["prettier"], "type_check": ["tsc"]}'
  ["python"]='{"linting": ["pylint", "flake8"], "testing": ["pytest", "unittest"], "formatting": ["black", "autopep8"], "type_check": ["mypy"]}'
  ["java"]='{"linting": ["checkstyle", "spotbugs"], "testing": ["junit", "testng"], "formatting": ["google-java-format"], "build": ["maven", "gradle"]}'
  ["go"]='{"linting": ["golint", "go vet"], "testing": ["go test"], "formatting": ["gofmt"], "build": ["go build"]}'
  ["rust"]='{"linting": ["clippy"], "testing": ["cargo test"], "formatting": ["rustfmt"], "build": ["cargo build"]}'
  
  # Extended languages
  ["kotlin"]='{"linting": ["ktlint"], "testing": ["junit"], "formatting": ["ktlint"], "build": ["gradle"]}'
  ["scala"]='{"linting": ["scalastyle"], "testing": ["scalatest"], "formatting": ["scalafmt"], "build": ["sbt"]}'
  ["swift"]='{"linting": ["swiftlint"], "testing": ["swift test"], "formatting": ["swift-format"], "build": ["swift build"]}'
  ["dart"]='{"linting": ["dart analyze"], "testing": ["flutter test"], "formatting": ["dart format"], "build": ["flutter build"]}'
  ["elixir"]='{"linting": ["credo"], "testing": ["mix test"], "formatting": ["mix format"], "build": ["mix compile"]}'
  ["clojure"]='{"linting": ["clj-kondo"], "testing": ["lein test"], "formatting": ["cljfmt"], "build": ["lein compile"]}'
  ["haskell"]='{"linting": ["hlint"], "testing": ["stack test"], "formatting": ["hindent"], "build": ["stack build"]}'
  ["lua"]='{"linting": ["luacheck"], "testing": ["busted"], "formatting": ["stylua"]}'
  ["r"]='{"linting": ["lintr"], "testing": ["testthat"], "formatting": ["styler"]}'
  ["julia"]='{"linting": ["Lint.jl"], "testing": ["Pkg.test"], "formatting": ["JuliaFormatter.jl"]}'
  ["shell"]='{"linting": ["shellcheck"], "testing": ["bats"], "formatting": ["shfmt"]}'
  ["powershell"]='{"linting": ["PSScriptAnalyzer"], "testing": ["Pester"], "formatting": ["PSScriptAnalyzer"]}'
  ["dockerfile"]='{"linting": ["hadolint"], "testing": ["container-structure-test"]}'
  ["yaml"]='{"linting": ["yamllint"], "formatting": ["prettier"]}'
  ["sql"]='{"linting": ["sqlfluff"], "formatting": ["sqlformat"]}'
)

# Generate tool commands for detected language
LINTING_COMMANDS=()
TEST_COMMANDS=()
FORMAT_COMMANDS=()
BUILD_COMMANDS=()

if [[ -n "${DEFAULT_TOOLS[$PRIMARY_LANG]}" ]]; then
    echo "Using built-in tool configuration for $PRIMARY_LANG"
    
    # Extract tool commands from configuration
    while IFS= read -r tool; do
        if [[ -n "$tool" ]]; then
            LINTING_COMMANDS+=("$tool")
        fi
    done < <(echo "${DEFAULT_TOOLS[$PRIMARY_LANG]}" | jq -r '.linting[]?' 2>/dev/null)
    
    while IFS= read -r tool; do
        if [[ -n "$tool" ]]; then
            TEST_COMMANDS+=("$tool")
        fi
    done < <(echo "${DEFAULT_TOOLS[$PRIMARY_LANG]}" | jq -r '.testing[]?' 2>/dev/null)
    
    while IFS= read -r tool; do
        if [[ -n "$tool" ]]; then
            FORMAT_COMMANDS+=("$tool")
        fi
    done < <(echo "${DEFAULT_TOOLS[$PRIMARY_LANG]}" | jq -r '.formatting[]?' 2>/dev/null)
    
    while IFS= read -r tool; do
        if [[ -n "$tool" ]]; then
            BUILD_COMMANDS+=("$tool")
        fi
    done < <(echo "${DEFAULT_TOOLS[$PRIMARY_LANG]}" | jq -r '.build[]?' 2>/dev/null)
    
else
    echo "No built-in configuration for $PRIMARY_LANG, using adaptive analysis"
    
    # Generate generic commands based on common patterns
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        TEST_COMMANDS+=("npm test")
        BUILD_COMMANDS+=("npm run build")
    elif [[ -f "$PROJECT_PATH/Cargo.toml" ]]; then
        TEST_COMMANDS+=("cargo test")
        BUILD_COMMANDS+=("cargo build")
    elif [[ -f "$PROJECT_PATH/go.mod" ]]; then
        TEST_COMMANDS+=("go test ./...")
        BUILD_COMMANDS+=("go build")
    elif [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        TEST_COMMANDS+=("python -m pytest")
        LINTING_COMMANDS+=("python -m py_compile")
    elif [[ -f "$PROJECT_PATH/pom.xml" ]]; then
        TEST_COMMANDS+=("mvn test")
        BUILD_COMMANDS+=("mvn compile")
    elif [[ -f "$PROJECT_PATH/build.gradle" ]]; then
        TEST_COMMANDS+=("./gradlew test")
        BUILD_COMMANDS+=("./gradlew build")
    elif [[ -f "$PROJECT_PATH/Makefile" ]]; then
        TEST_COMMANDS+=("make test")
        BUILD_COMMANDS+=("make")
    fi
fi

echo "Generated linting commands: ${LINTING_COMMANDS[*]}"
echo "Generated test commands: ${TEST_COMMANDS[*]}"
echo "Generated format commands: ${FORMAT_COMMANDS[*]}"
echo "Generated build commands: ${BUILD_COMMANDS[*]}"
```

### 5. Generic Quality Analysis
```bash
echo "=== Generic Quality Analysis ==="

# Universal quality metrics that work for any language
GENERIC_METRICS=()

# 1. File size analysis
echo "Analyzing file sizes..."
LARGE_FILES=$(find "$PROJECT_PATH" -type f -size +100k | grep -v node_modules | grep -v ".git" | wc -l)
VERY_LARGE_FILES=$(find "$PROJECT_PATH" -type f -size +500k | grep -v node_modules | grep -v ".git" | wc -l)
GENERIC_METRICS+=("large_files:$LARGE_FILES")
GENERIC_METRICS+=("very_large_files:$VERY_LARGE_FILES")

# 2. Directory depth analysis
echo "Analyzing directory structure..."
MAX_DEPTH=$(find "$PROJECT_PATH" -type d | awk -F/ '{print NF}' | sort -n | tail -1)
DEEP_DIRS=$(find "$PROJECT_PATH" -type d | awk -F/ 'NF > 10' | wc -l)
GENERIC_METRICS+=("max_depth:$MAX_DEPTH")
GENERIC_METRICS+=("deep_directories:$DEEP_DIRS")

# 3. Code duplication (text-based)
echo "Detecting text-based duplication..."
TEMP_CODE_FILE="/tmp/all_code_lines_$$"
> "$TEMP_CODE_FILE"

# Extract code lines from all relevant files
for lang in "${!EXTENDED_LANG_PATTERNS[@]}"; do
    for pattern in ${EXTENDED_LANG_PATTERNS[$lang]}; do
        find "$PROJECT_PATH" -name "$pattern" -type f 2>/dev/null | while read -r file; do
            grep -v "^[[:space:]]*$" "$file" 2>/dev/null | \
            grep -v "^[[:space:]]*//\|^[[:space:]]*#\|^[[:space:]]*\*" >> "$TEMP_CODE_FILE"
        done
    done
done

if [[ -f "$TEMP_CODE_FILE" ]]; then
    total_lines=$(wc -l < "$TEMP_CODE_FILE")
    unique_lines=$(sort "$TEMP_CODE_FILE" | uniq | wc -l)
    duplicate_lines=$((total_lines - unique_lines))
    
    if [[ $total_lines -gt 0 ]]; then
        duplication_percentage=$(echo "scale=2; $duplicate_lines * 100 / $total_lines" | bc 2>/dev/null || echo "0")
    else
        duplication_percentage="0"
    fi
    
    GENERIC_METRICS+=("total_lines:$total_lines")
    GENERIC_METRICS+=("duplicate_lines:$duplicate_lines")
    GENERIC_METRICS+=("duplication_percentage:$duplication_percentage")
    
    rm -f "$TEMP_CODE_FILE"
fi

# 4. Comment ratio analysis
echo "Analyzing comment ratio..."
COMMENT_LINES=0
CODE_LINES=0

for lang in "${!EXTENDED_LANG_PATTERNS[@]}"; do
    for pattern in ${EXTENDED_LANG_PATTERNS[$lang]}; do
        find "$PROJECT_PATH" -name "$pattern" -type f 2>/dev/null | while read -r file; do
            if [[ -f "$file" ]]; then
                comments=$(grep -c "^[[:space:]]*//\|^[[:space:]]*#\|^[[:space:]]*\*\|^[[:space:]]*/\*" "$file" 2>/dev/null || echo 0)
                total=$(wc -l < "$file")
                code=$((total - comments))
                
                echo "$comments" >> "/tmp/comments_$$"
                echo "$code" >> "/tmp/code_$$"
            fi
        done
    done
done

if [[ -f "/tmp/comments_$$" ]]; then
    COMMENT_LINES=$(paste -sd+ "/tmp/comments_$$" | bc 2>/dev/null || echo 0)
    CODE_LINES=$(paste -sd+ "/tmp/code_$$" | bc 2>/dev/null || echo 0)
    
    if [[ $CODE_LINES -gt 0 ]]; then
        comment_ratio=$(echo "scale=2; $COMMENT_LINES * 100 / ($CODE_LINES + $COMMENT_LINES)" | bc 2>/dev/null || echo "0")
    else
        comment_ratio="0"
    fi
    
    GENERIC_METRICS+=("comment_lines:$COMMENT_LINES")
    GENERIC_METRICS+=("code_lines:$CODE_LINES")
    GENERIC_METRICS+=("comment_ratio:$comment_ratio")
    
    rm -f "/tmp/comments_$$" "/tmp/code_$$"
fi

echo "Generic metrics collected: ${GENERIC_METRICS[*]}"
```

### 6. Save Language Profile
```bash
echo "=== Saving Language Profile ==="

if [[ "$SAVE_PROFILE" == "true" && "$PRIMARY_LANG" != "unknown" ]]; then
    # Create language profile for future use
    PROFILE_DATA=$(cat <<EOF
{
  "language": "$PRIMARY_LANG",
  "patterns": [$(printf '"%s",' ${EXTENDED_LANG_PATTERNS[$PRIMARY_LANG]} | sed 's/,$///')],
  "linting_commands": [$(printf '"%s",' "${LINTING_COMMANDS[@]}" | sed 's/,$///')],
  "test_commands": [$(printf '"%s",' "${TEST_COMMANDS[@]}" | sed 's/,$///')],
  "format_commands": [$(printf '"%s",' "${FORMAT_COMMANDS[@]}" | sed 's/,$///')],
  "build_commands": [$(printf '"%s",' "${BUILD_COMMANDS[@]}" | sed 's/,$///')],
  "generic_metrics": [$(printf '"%s",' "${GENERIC_METRICS[@]}" | sed 's/,$///')],
  "detection_confidence": $(([[ $MAX_COUNT -gt 0 ]] && echo "high" || echo "low")),
  "created_at": "$(date -Iseconds)",
  "project_path": "$PROJECT_PATH"
}
EOF
)

    # Update custom languages file
    jq --argjson profile "$PROFILE_DATA" \
       ".languages[\"$PRIMARY_LANG\"] = \$profile | .last_updated = \"$(date -Iseconds)\"" \
       "$CUSTOM_LANGS_FILE" > "$CUSTOM_LANGS_FILE.tmp" && mv "$CUSTOM_LANGS_FILE.tmp" "$CUSTOM_LANGS_FILE"
    
    echo "✅ Language profile saved for $PRIMARY_LANG"
fi
```

### 7. Generate Adaptive Configuration
```bash
echo "=== Generating Adaptive Configuration ==="

# Create project-specific configuration
ADAPTIVE_CONFIG="$PROJECT_PATH/.ai_workflow/cache/quality/adaptive_config.json"
mkdir -p "$(dirname "$ADAPTIVE_CONFIG")"

cat > "$ADAPTIVE_CONFIG" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "primary_language": "$PRIMARY_LANG",
  "secondary_languages": [$(printf '"%s",' "${SECONDARY_LANGS[@]}" | sed 's/,$///')],
  "linting_commands": [$(printf '"%s",' "${LINTING_COMMANDS[@]}" | sed 's/,$///')],
  "test_commands": [$(printf '"%s",' "${TEST_COMMANDS[@]}" | sed 's/,$///')],
  "format_commands": [$(printf '"%s",' "${FORMAT_COMMANDS[@]}" | sed 's/,$///')],
  "build_commands": [$(printf '"%s",' "${BUILD_COMMANDS[@]}" | sed 's/,$///')],
  "generic_metrics": [$(printf '"%s",' "${GENERIC_METRICS[@]}" | sed 's/,$///')],
  "analysis_strategy": "$(([[ "$PRIMARY_LANG" != "unknown" ]] && echo "language_specific" || echo "generic"))",
  "confidence_level": "$(([[ $MAX_COUNT -gt 10 ]] && echo "high" || ([[ $MAX_COUNT -gt 0 ]] && echo "medium" || echo "low")))",
  "recommendations": [
    $(([[ ${#LINTING_COMMANDS[@]} -eq 0 ]] && echo '"Consider adding linting tools for better code quality",' || echo ''))
    $(([[ ${#TEST_COMMANDS[@]} -eq 0 ]] && echo '"Consider adding testing framework for better reliability",' || echo ''))
    $(([[ "$PRIMARY_LANG" == "unknown" ]] && echo '"Language detection confidence low, consider specifying language in PRD",' || echo ''))
    "Framework successfully adapted to your project structure"
  ]
}
EOF

echo "✅ Adaptive configuration generated: $ADAPTIVE_CONFIG"

# Output summary
echo "=== Adaptive Language Support Summary ==="
echo "Primary Language: $PRIMARY_LANG"
echo "Secondary Languages: ${SECONDARY_LANGS[*]:-none}"
echo "Linting Tools: ${#LINTING_COMMANDS[@]} configured"
echo "Testing Tools: ${#TEST_COMMANDS[@]} configured"
echo "Analysis Strategy: $(([[ "$PRIMARY_LANG" != "unknown" ]] && echo "Language-specific" || echo "Generic fallback"))"
echo "Confidence Level: $(([[ $MAX_COUNT -gt 10 ]] && echo "High" || ([[ $MAX_COUNT -gt 0 ]] && echo "Medium" || echo "Low")))"

# Set exit code based on configuration success
if [[ "$PRIMARY_LANG" != "unknown" || ${#GENERIC_METRICS[@]} -gt 0 ]]; then
    echo "✅ Adaptive language support configured successfully"
    exit 0
else
    echo "⚠️  Limited language support, using minimal generic analysis"
    exit 1
fi
```

## Error Handling
- **No Files Detected**: Falls back to generic analysis
- **Unknown Language**: Uses universal metrics and file-based analysis
- **Missing Tools**: Provides graceful degradation with basic validation
- **Configuration Errors**: Continues with minimal viable configuration

## Integration Points
- **PRD Creation**: Automatically extracts language information from PRDs
- **Quality Gates**: Provides adaptive tool configuration
- **Project Detection**: Enhances language detection with learning capabilities
- **User Configuration**: Minimal intervention required

## Output Format
```json
{
  "primary_language": "kotlin",
  "linting_commands": ["ktlint"],
  "test_commands": ["./gradlew test"],
  "analysis_strategy": "language_specific",
  "confidence_level": "high",
  "generic_metrics": ["large_files:2", "duplication_percentage:3.5"]
}
```

## Benefits
- **Zero Configuration**: Works out of the box for 30+ languages
- **Self-Learning**: Improves language support over time
- **PRD Integration**: Leverages existing project information
- **Graceful Degradation**: Provides useful analysis even for unknown languages
- **Minimal User Intervention**: Requires input only when absolutely necessary