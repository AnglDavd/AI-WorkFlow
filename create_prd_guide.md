# [STEP-01] PRD Creation Master Guide

**WORKFLOW-POSITION:** Step 1 of 3 (PRD → TASKS → EXECUTION)
**INPUT-FILE:** Interactive interview process
**OUTPUT-FILE:** `01_prd_{session-id}_{project-name}.md`
**NEXT-STEP:** `./ai-dev generate 01_prd_{session-id}_{project-name}.md`

**CRITICAL-GENERATION-LOGIC:**
```bash
# Generate collision-resistant session ID with timestamp + random
TIMESTAMP=$(date +%s)
RANDOM_PART=$(shuf -i 100-999 -n 1)
SESSION_ID="${TIMESTAMP: -3}${RANDOM_PART}"          # Last 3 digits of timestamp + 3 random digits

# Validate session ID format and uniqueness
if [ -z "$SESSION_ID" ] || ! [[ "$SESSION_ID" =~ ^[0-9]{6}$ ]]; then
    SESSION_ID=$(shuf -i 100000-999999 -n 1)        # Fallback: 6-digit random number
fi

# Check for existing files with same session ID (collision detection)
if ls *_${SESSION_ID}_*.md >/dev/null 2>&1; then
    echo "⚠️  Session ID collision detected: $SESSION_ID"
    SESSION_ID=$(shuf -i 100000-999999 -n 1)        # Generate new random ID
    echo "✅ New session ID generated: $SESSION_ID"
fi

# CRITICAL: Extract project name from actual user input
echo "🔍 Extracting project name from user conversation..."

# Get last user message from context (implementation specific)
if [ -n "$LAST_USER_MESSAGE" ]; then
    USER_INPUT="$LAST_USER_MESSAGE"
else
    # Fallback: prompt for input if context not available
    echo "⚠️  Context not available. Please provide project description:"
    read -p "Project description: " USER_INPUT
fi

# Extract project name using defined function
PROJECT_NAME=$(extract_project_name "$USER_INPUT")

# Validate extraction was successful
if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "app-system" ]; then
    echo "❌ Could not extract meaningful project name from: '$USER_INPUT'"
    echo "ℹ️  Please provide a project name in format: technology-purpose-modifier"
    echo "📝 Examples: react-ecommerce-app, wordpress-pos-plugin, vue-dashboard-admin"
    read -p "Project name: " MANUAL_PROJECT_NAME
    PROJECT_NAME=$(validate_project_name "$MANUAL_PROJECT_NAME")
fi

# Validate and sanitize project name before file creation
validate_project_name() {
    local name="$1"
    # Remove invalid characters and ensure kebab-case
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g')
    # Ensure length constraints
    if [ ${#name} -lt 3 ] || [ ${#name} -gt 50 ]; then
        echo "ERROR: Project name must be 3-50 characters after sanitization"
        return 1
    fi
    echo "$name"
}

OUTPUT_FILE="01_prd_${SESSION_ID}_${PROJECT_NAME}.md" # Result: 01_prd_abc123_wordpress-plugin.md

echo "✅ Generated SESSION_ID: $SESSION_ID"
echo "✅ Project name will be extracted and validated during interview"
echo "✅ Output file pattern: $OUTPUT_FILE"
```

**PROJECT-NAME-EXTRACTION-RULES:**
```bash
# MANDATORY: Follow these exact rules for project naming
extract_project_name() {
    local user_input="$1"
    
    # 1. Extract key technology/platform (REQUIRED) - Case insensitive with broader patterns
    PLATFORM=$(echo "$user_input" | grep -Eio "wordpress|woocommerce|react|vue|angular|laravel|django|node|express|android|ios|flutter|kotlin|swift|php|python|java|go|ruby|nextjs|nuxt" | head -1 | tr '[:upper:]' '[:lower:]')
    
    # 2. Extract primary function/purpose (REQUIRED) - Enhanced patterns  
    PURPOSE=$(echo "$user_input" | grep -Eio "plugin|app|application|website|web|api|dashboard|pos|ecommerce|e-commerce|blog|cms|system|platform|store|shop|portal|service" | head -1 | tr '[:upper:]' '[:lower:]')
    
    # Normalize common terms to standard values
    case $PURPOSE in
        "application") PURPOSE="app" ;;
        "e-commerce") PURPOSE="ecommerce" ;;
        "web"|"website") PURPOSE="website" ;;
        "shop") PURPOSE="store" ;;
    esac
    
    # 3. Extract geographic/domain modifier (OPTIONAL) - International scope
    MODIFIER=$(echo "$user_input" | grep -Eio "international|global|local|regional|mobile|admin|complete|simple|basic|advanced|enterprise|startup|b2b|b2c|saas|paas" | head -1 | tr '[:upper:]' '[:lower:]')
    
    # Normalize modifiers to standard values
    case $MODIFIER in
        "basic") MODIFIER="simple" ;;
        "enterprise") MODIFIER="advanced" ;;
    esac
    
    # 4. Construct project name (kebab-case, 2-4 words max)
    if [ -n "$MODIFIER" ]; then
        PROJECT_NAME="${PLATFORM:-app}-${PURPOSE:-system}-${MODIFIER}"
    else
        PROJECT_NAME="${PLATFORM:-app}-${PURPOSE:-system}"
    fi
    
    # 5. Validate and clean
    PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g')
    
    echo "$PROJECT_NAME"
}

# Examples:
# "plugin para WordPress" → "wordpress-plugin"
# "POS para WooCommerce en Chile" → "woocommerce-pos-chile"  
# "app React e-commerce" → "react-ecommerce-app"
# "API Laravel para mobile" → "laravel-api-mobile"
```

**VALIDATION-REQUIREMENTS:**
- Project name MUST be 2-4 words in kebab-case
- MUST include primary technology if mentioned
- MUST include primary purpose/function
- NO special characters except hyphens
- Length: 10-40 characters maximum

**Role:** Expert Product Manager with 15+ years creating comprehensive PRDs

**Objective:** Create ultra-detailed Product Requirements Document through comprehensive interview

**Structure Philosophy:** Sequential workflow with session ID for perfect traceability

## Interview Process

### Section 1: Project Vision
- Project name and description
- Problem statement and target audience  
- Business goals and success metrics
- Vision and inspiration behind project

### Section 2: Technical Requirements
- Technology stack (frontend, backend, database, tools)
- Platform requirements (web, mobile, desktop, browsers)
- Architecture approach (monolith, microservices, APIs)
- Performance, security, and scalability needs

### Section 3: Functional Requirements  
- Core features list with detailed descriptions
- User stories: "As a [user], I want [goal] so that [benefit]"
- User workflows and main use cases
- Edge cases and error handling scenarios

### Section 4: Implementation Details
- File structure and project organization
- Development environment setup requirements
- Deployment strategy and CI/CD preferences
- Testing approach and quality requirements

### Section 5: Project Planning
- Timeline, phases, and key milestones
- Dependencies and external factors
- Risks and mitigation strategies
- Constraints and assumptions

## Output Template

```markdown
# Product Requirements Document

## Document Information
- **Project Name:** [Name]
- **Created:** [Date]
- **Version:** 1.0

## 1. Project Overview
[Vision, problem, audience, goals, metrics]

## 2. Technology Stack Analysis
[AI-generated options with complexity analysis]

## 3. Technical Requirements  
[Architecture, performance, security based on chosen stack]

## 4. Functional Requirements
[Features, user stories, workflows, edge cases]

## 5. Implementation Details
[File structure, environment, deployment, testing]

## 6. Project Planning
[Timeline, dependencies, risks, constraints]
```

**TECHNOLOGY-STACK-ANALYSIS-WORKFLOW:**
```bash
# MANDATORY: Execute complexity analysis and present technology options
analyze_project_complexity() {
    local user_requirements="$1"
    
    # Analyze complexity indicators
    local feature_count=$(echo "$user_requirements" | grep -ci "feature\|function\|capability\|module")
    local user_scale=$(echo "$user_requirements" | grep -Eo "[0-9]+ users?" | head -1 | grep -Eo "[0-9]+")
    local integrations=$(echo "$user_requirements" | grep -ci "integration\|API\|payment\|third-party\|external")
    local real_time=$(echo "$user_requirements" | grep -ci "real-time\|live\|instant\|notification")
    local mobile=$(echo "$user_requirements" | grep -ci "mobile\|responsive\|app")
    local admin=$(echo "$user_requirements" | grep -ci "admin\|dashboard\|management\|report")
    
    # Set defaults if extraction fails
    feature_count=${feature_count:-3}
    user_scale=${user_scale:-50}
    integrations=${integrations:-0}
    
    # Complexity scoring (0-100 scale)
    local complexity_score=0
    
    # Feature count scoring (0-25 points)
    if [ $feature_count -gt 15 ]; then
        complexity_score=$((complexity_score + 25))
    elif [ $feature_count -gt 8 ]; then
        complexity_score=$((complexity_score + 15))
    elif [ $feature_count -gt 4 ]; then
        complexity_score=$((complexity_score + 8))
    fi
    
    # User scale scoring (0-20 points)
    if [ $user_scale -gt 10000 ]; then
        complexity_score=$((complexity_score + 20))
    elif [ $user_scale -gt 1000 ]; then
        complexity_score=$((complexity_score + 15))
    elif [ $user_scale -gt 100 ]; then
        complexity_score=$((complexity_score + 8))
    fi
    
    # Integration scoring (0-25 points)
    complexity_score=$((complexity_score + integrations * 5))
    if [ $complexity_score -gt 25 ]; then complexity_score=25; fi
    
    # Additional features scoring (0-30 points)
    [ $real_time -gt 0 ] && complexity_score=$((complexity_score + 10))
    [ $mobile -gt 0 ] && complexity_score=$((complexity_score + 8))
    [ $admin -gt 0 ] && complexity_score=$((complexity_score + 5))
    
    # Determine complexity level
    if [ $complexity_score -ge 70 ]; then
        echo "Complex"
    elif [ $complexity_score -ge 35 ]; then
        echo "Medium"
    else
        echo "Simple"
    fi
}

present_technology_options() {
    local complexity="$1"
    local user_requirements="$2"
    
    echo "## 2. Technology Stack Analysis"
    echo ""
    echo "**Complexity Assessment:** $complexity"
    echo "**Analysis Date:** $(date '+%Y-%m-%d')"
    echo ""
    
    case $complexity in
        "Simple")
            cat << 'EOF'
### Recommended Technology Options

#### Option 1: Minimal Stack ⭐ **RECOMMENDED**
**Best for:** Simple applications, fast development, easy maintenance
- **Backend:** PHP 8+ with built-in server capabilities
- **Frontend:** HTML5 + CSS3 + Vanilla JavaScript
- **Database:** SQLite (file-based, no server needed)
- **Hosting:** Shared hosting or simple VPS
- **Development Time:** 4-6 weeks
- **Maintenance Effort:** Very Low
- **Cost Range:** $5,000 - $10,000
- **Hosting Cost:** $5-20/month

**Pros:**
- Fastest development and deployment
- Minimal hosting requirements
- Easy to maintain and update
- Low ongoing costs
- Perfect for MVP and simple applications

**Cons:**
- Limited scalability beyond 1000 users
- Basic feature set
- Manual optimization needed for performance

#### Option 2: Enhanced Simple Stack
**Best for:** Growing applications with moderate traffic
- **Backend:** Node.js + Express + SQLite
- **Frontend:** HTML + CSS + Vanilla JS (with build tools)
- **Database:** SQLite → PostgreSQL migration path
- **Hosting:** VPS or Platform-as-a-Service
- **Development Time:** 6-8 weeks
- **Maintenance Effort:** Low
- **Cost Range:** $8,000 - $15,000
- **Hosting Cost:** $15-50/month

**Pros:**
- Modern JavaScript ecosystem
- Easy scaling path
- Good performance
- npm ecosystem access

**Cons:**
- Slightly more complex setup
- Node.js hosting requirements
- More moving parts to maintain

### **AI Recommendation:** Option 1 (Minimal Stack)
**Reasoning:** Based on requirements analysis, a simple stack will deliver faster results with lower complexity and maintenance overhead.
EOF
            ;;
        "Medium")
            cat << 'EOF'
### Recommended Technology Options

#### Option 1: Balanced Modern Stack ⭐ **RECOMMENDED**
**Best for:** Professional applications with growth potential
- **Backend:** Python + FastAPI + PostgreSQL
- **Frontend:** Next.js + React + Tailwind CSS
- **Database:** PostgreSQL with Redis for caching
- **Hosting:** Cloud platform (Vercel/Railway/DigitalOcean)
- **Development Time:** 8-12 weeks
- **Maintenance Effort:** Medium
- **Cost Range:** $15,000 - $25,000
- **Hosting Cost:** $30-100/month

**Pros:**
- Excellent scalability up to 50,000+ users
- Modern development experience
- Strong typing with TypeScript
- Robust ecosystem and community
- Great performance out of the box

**Cons:**
- More complex initial setup
- Higher hosting costs
- Requires more technical expertise

#### Option 2: PHP Professional Stack
**Best for:** Teams familiar with PHP, shared hosting preferences
- **Backend:** PHP + Laravel + MySQL
- **Frontend:** Vue.js + Bootstrap
- **Database:** MySQL with Redis
- **Hosting:** VPS or managed hosting
- **Development Time:** 10-14 weeks
- **Maintenance Effort:** Medium
- **Cost Range:** $12,000 - $20,000
- **Hosting Cost:** $20-80/month

**Pros:**
- Mature ecosystem
- Excellent documentation
- Wide hosting availability
- Strong MVC architecture

**Cons:**
- Slower development compared to modern stacks
- Less trendy but very stable
- Traditional architecture patterns

### **AI Recommendation:** Option 1 (Balanced Modern Stack)
**Reasoning:** Provides the best balance of development speed, scalability, and modern features for medium complexity projects.
EOF
            ;;
        "Complex")
            cat << 'EOF'
### Recommended Technology Options

#### Option 1: Enterprise Modern Stack ⭐ **RECOMMENDED**
**Best for:** Large-scale applications, enterprise features
- **Backend:** Python + Django + PostgreSQL + Redis + Celery
- **Frontend:** Next.js + TypeScript + Tailwind + Zustand
- **Database:** PostgreSQL with read replicas
- **Infrastructure:** Docker + Kubernetes or managed cloud
- **Development Time:** 16-24 weeks
- **Maintenance Effort:** High
- **Cost Range:** $30,000 - $60,000
- **Hosting Cost:** $100-500/month

**Pros:**
- Handles massive scale (100,000+ users)
- Enterprise-grade security and features
- Microservices architecture ready
- Advanced caching and optimization
- Comprehensive admin capabilities

**Cons:**
- High complexity and learning curve
- Expensive hosting and maintenance
- Requires experienced development team
- Longer development time

#### Option 2: Full-Stack JavaScript Enterprise
**Best for:** JavaScript-focused teams, real-time features
- **Backend:** Node.js + NestJS + TypeScript + PostgreSQL
- **Frontend:** Next.js + TypeScript + Material-UI
- **Real-time:** Socket.io + Redis
- **Infrastructure:** Docker + Cloud platforms
- **Development Time:** 18-26 weeks
- **Maintenance Effort:** High
- **Cost Range:** $35,000 - $70,000
- **Hosting Cost:** $150-600/month

**Pros:**
- Unified language across stack
- Excellent for real-time features
- Strong typing throughout
- Great development tooling

**Cons:**
- Node.js performance limitations for CPU-intensive tasks
- Complex deployment and scaling
- Higher memory usage

### **AI Recommendation:** Option 1 (Enterprise Modern Stack)
**Reasoning:** Django provides battle-tested enterprise features with excellent scalability and security for complex applications.
EOF
            ;;
    esac
    
    echo ""
    echo "### Technology Selection Process"
    echo "1. **Review Options:** Analyze each option's pros, cons, and costs"
    echo "2. **Select Stack:** Choose based on team expertise and project needs"
    echo "3. **Approve Choice:** Add comment to PRD: \`<!-- TECH_APPROVED: option-1 -->\`"
    echo "4. **Generate Tasks:** Run \`./ai-dev generate\` to create implementation plan"
    echo ""
    echo "**Note:** Technology stack can be reviewed and changed before task generation using:"
    echo "\`./ai-dev collaborate --review-tech [session-id]\`"
}

# EXECUTION: Run analysis and present options
echo "🔍 Analyzing project complexity from user requirements..."
PROJECT_COMPLEXITY=$(analyze_project_complexity "$USER_INPUT")
echo "✅ Complexity determined: $PROJECT_COMPLEXITY"

echo "🤖 Generating technology stack options..."
TECH_OPTIONS=$(present_technology_options "$PROJECT_COMPLEXITY" "$USER_INPUT")
echo "✅ Technology options prepared for PRD"
```

**MANDATORY-QUALITY-REQUIREMENTS:**
- **Word Count:** 3000-5000 words (validate before submission)
- **Sections:** All 6 sections must be completed comprehensively (including Technology Analysis)
- **Technical Detail:** Specific enough for developers to estimate accurately
- **Technology Options:** At least 2 options with detailed analysis
- **Business Context:** Clear value proposition and success metrics
- **Implementation Readiness:** No ambiguous requirements

**QUALITY-VALIDATION-CHECKLIST:**
- [ ] Project Overview: Vision, problem, audience clearly defined
- [ ] Technical Requirements: Complete tech stack specified
- [ ] Functional Requirements: User stories with acceptance criteria
- [ ] Implementation Details: File structure and deployment strategy
- [ ] Project Planning: Timeline, dependencies, risks identified
- [ ] Budget Estimate: Realistic cost range provided
- [ ] Success Metrics: Measurable KPIs defined

**CONTENT-REQUIREMENTS:**
- Each user story MUST include: "As a [user], I want [goal] so that [benefit]"
- Each feature MUST include: functional details + edge cases
- Technical architecture MUST include: specific technologies + rationale
- Timeline MUST include: phases + milestones + dependencies
- Budget MUST align with: scope + timeline + team size

**CRITICAL-VALIDATION:**
Before completing PRD, verify:
1. Word count >= 3000 words
2. All sections substantive (not placeholder text)
3. Technical requirements specific enough to code from
4. Budget realistic for described scope
5. Timeline achievable with specified team

**ERROR-HANDLING-PROCEDURES:**

**Insufficient Information:**
If user provides vague requirements:
1. **STOP** and request specific clarification
2. Ask targeted questions: "What specific features do you need?"
3. Provide examples: "E.g., user authentication, payment processing, etc."
4. **DO NOT** assume or invent requirements

**Contradictory Requirements:**
If user provides conflicting information:
1. **IDENTIFY** the specific contradiction
2. **PRESENT** both options clearly to user
3. **REQUEST** explicit choice with rationale
4. **DOCUMENT** the decision in PRD

**Scope vs Budget Mismatch:**
If described scope exceeds stated budget:
1. **CALCULATE** realistic budget for described scope
2. **PRESENT** options: reduce scope OR increase budget
3. **RECOMMEND** specific features to prioritize/defer
4. **DO NOT** proceed with unrealistic expectations

**Technical Impossibilities:**
If requirements are technically unfeasible:
1. **EXPLAIN** the technical limitation clearly
2. **SUGGEST** alternative approaches that achieve similar goals
3. **REQUEST** user preference for workaround vs scope change
4. **DOCUMENT** technical constraints in PRD

**Incomplete Interview:**
If conversation lacks critical information:
```
REQUIRED MINIMUMS:
- Project purpose and target users
- Basic technology preferences
- Rough timeline expectations
- Approximate budget range
- Key features (at least 3-5)

If ANY of these missing: STOP and request before proceeding
```

**FALLBACK-RESPONSES:**
- "I need more specific information about [X] to create an accurate PRD"
- "This requirement conflicts with [Y]. Please clarify which takes priority"
- "The described scope typically requires $X budget. Should we adjust scope or budget?"
- "This feature isn't technically feasible with [technology]. Would [alternative] work?"