# Claude AI Development Framework - Memory & Best Practices

**Framework Version:** v3.1.1 Enhanced with Context7 Integration  
**Last Updated:** 2025-01-20  
**Status:** Production Ready with Iterative Quality Loop

---

## 🎯 Framework Overview

This is an ultra-efficient AI development framework optimized for speed, quality, and real-world results. The framework has been enhanced with:

- **Smart contextual questioning** (60% time reduction in PRD creation)
- **Auto-completion with Context7** research integration
- **Realistic automatic estimates** based on current market rates
- **Iterative quality loop** until 8/10+ achieved across all dimensions
- **MCP integration** for Playwright visual analysis and Context7 research

---

## 🚀 Quick Start Commands

### Core Workflow Commands
```bash
# 1. Create PRD (Enhanced with smart questioning)
./ai-dev create

# 2. Generate Tasks (Enhanced with Context7 validation)
./ai-dev generate 01_prd_{session-id}_{project-name}.md

# 3. Execute Implementation (Enhanced with iterative quality)
./ai-dev execute 02_tasks_{session-id}_{project-name}.md

# 4. Run Iterative Quality Loop (NEW - replaces single healing)
./ai-dev iterate quality {session-id}

# 5. Force healing analysis (legacy support)
./ai-dev heal {session-id}
```

### Management Commands
```bash
# List all sessions
./ai-dev list

# Show session details
./ai-dev status {session-id}

# Resume working on a session
./ai-dev resume {session-id}

# Archive completed session
./ai-dev archive {session-id}
```

---

## 📋 Enhanced Workflow Features

### 1. Smart PRD Creation
- **Auto-detects project type** in 1 question (vs 15+ follow-ups)
- **Context-specific questions** (6-8 vs 20+ generic)
- **Auto-completion** with Context7 research
- **Realistic estimates** based on current market rates

**Key Efficiency Gains:**
- Interview time: 15 minutes (was 45+ minutes)
- Higher quality responses due to relevant context
- Auto-populated tech stack suggestions
- Market-validated cost and timeline estimates

### 2. Enhanced Task Generation
- **MCP Context7 validation** of tech stacks
- **Current best practices** research integration
- **Automatic complexity determination**
- **Cross-validation** with PRD requirements

### 3. Iterative Quality Execution
- **Maximum 5 iterations** until 8/10+ achieved
- **Automatic improvement** generation and application
- **Context7-enhanced** standards research
- **Quality certification** before completion

---

## 🔧 MCP Integration Requirements

### Required MCP Tools
```bash
# Install MCP Playwright for UI analysis
claude mcp add playwright npx '@playwright/mcp@latest'

# Verify installation
claude mcp list | grep playwright
```

### Context7 Integration
- Used for real-time research of current best practices
- Validates tech stack choices against 2025 trends
- Provides market rate data for realistic estimates
- Enhances quality standards with latest industry benchmarks

---

## 📊 Quality Standards

### Mandatory Quality Thresholds (ALL must be >= 8/10)
- **Visual Consistency:** 20% weight - Design system adherence
- **CRO Optimization:** 25% weight - Conversion rate optimization  
- **Accessibility:** 20% weight - WCAG 2.1 compliance
- **Architecture Quality:** 15% weight - Code structure quality
- **Performance:** 10% weight - Load times and optimization
- **Responsive Design:** 10% weight - Multi-device support

### Quality Enforcement
- **Automatic blocking** if any dimension < 8/10
- **Iterative improvement** until threshold met
- **Maximum 5 iterations** before manual review required
- **Quality certification** seal for approved projects

---

## 🎨 Project Complexity Detection

### Automatic Classification
```bash
Simple      | 10-15 tasks  | $2K-$10K   | 3-8 weeks  | 1-2 devs
Medium      | 15-25 tasks  | $10K-$25K  | 8-16 weeks | 2-3 devs  
Complex     | 25-40 tasks  | $25K-$60K  | 16-24 weeks| 3-5 devs
Enterprise  | 40+ tasks    | $60K+      | 24+ weeks  | 5+ devs
```

### Tech Stack Recommendations
- **React/Next.js:** +15% premium (high demand)
- **WordPress:** -10% efficiency (rapid development)
- **Laravel/Django:** Standard rates
- **Enterprise features:** +20% (compliance overhead)

---

## 📁 File Structure & Session Management

### Session ID Format
- **Pattern:** `{timestamp-3digits}{random-3digits}` (e.g., 592846)
- **Collision detection** and auto-regeneration
- **Perfect traceability** across all workflow files

### Generated Files
```
01_prd_{session-id}_{project-name}.md      # PRD with smart questioning
02_tasks_{session-id}_{project-name}.md    # Tasks with Context7 validation
03_report_{session-id}_{project-name}.md   # Execution report
03_quality_{session-id}_{project-name}.md  # Quality certification
```

---

## ⚡ Performance Optimizations

### PRD Creation Efficiency
- **60% time reduction** through smart questioning
- **Auto-completion** reduces technical decisions from 30+ min to 5 min
- **Market research** provides realistic estimates instantly
- **Context-aware** suggestions based on project type

### Task Generation Enhancement
- **Context7 validation** of tech stack patterns
- **Current best practices** integration
- **Automatic feasibility** validation
- **Cross-PRD consistency** checking

### Execution Improvements
- **Iterative quality loop** replaces single-pass healing
- **Automatic improvement** generation and application
- **Real-time research** integration during iterations
- **Quality certification** with professional standards

---

## 🔄 Iterative Quality Loop Details

### Loop Execution
1. **Comprehensive audit** with MCP Playwright + Context7
2. **Score calculation** across all 6 dimensions
3. **Threshold validation** (all >= 8/10)
4. **Research improvement** strategies if needed
5. **Generate targeted** improvements
6. **Apply automatic** fixes
7. **Repeat until** quality achieved (max 5 iterations)

### Success Criteria
- ✅ ALL dimensions >= 8/10
- ✅ Professional quality standards exceeded
- ✅ Production deployment approved
- ✅ Quality certification seal applied

---

## 🛠️ Common Usage Patterns

### New Project Workflow
```bash
# 1. Start with smart PRD creation
./ai-dev create
# → Answer 6-8 contextual questions (15 min)
# → Get auto-completed tech stack suggestions
# → Receive realistic market-based estimates

# 2. Generate enhanced task plan
./ai-dev generate 01_prd_{session-id}_{project-name}.md
# → Context7-validated tech stack patterns
# → Current best practices integration
# → Automatic complexity determination

# 3. Execute with iterative quality
./ai-dev execute 02_tasks_{session-id}_{project-name}.md
# → Automatic iterative quality loop
# → Maximum 5 iterations until 8/10+
# → Quality certification before completion
```

### Resume Existing Session
```bash
# Check session status
./ai-dev status {session-id}

# Resume where left off
./ai-dev resume {session-id}

# Force quality check if needed
./ai-dev iterate quality {session-id}
```

### Quality Validation
```bash
# Run quality analysis independently
./ai-dev iterate quality {session-id}

# Check if project meets standards
./ai-dev status {session-id} --quality

# Generate quality report
./ai-dev report {session-id} --quality
```

---

## 📊 Complete Framework Structure (Hierarchical Overview)

### 1. **FRAMEWORK CORE**
   1.1. **Main CLI** (`ai-dev`)
       - 1.1.1. Core Commands (create, generate, execute, iterate)
       - 1.1.2. Management Commands (list, status, resume, archive)
       - 1.1.3. Session ID Generation & Validation
   
   1.2. **Session Management System**
       - 1.2.1. Collision-resistant Session IDs (`{timestamp-3}{random-3}`)
       - 1.2.2. Perfect File Traceability
       - 1.2.3. Cross-file Consistency Validation

### 2. **WORKFLOW PHASES** (Sequential, Session-linked)
   2.1. **Phase 1: Smart PRD Creation** (`create_prd_guide.md`)
       - 2.1.1. **Smart Project Classification** (1 question → project type)
       - 2.1.2. **Context-Specific Questioning** (6-8 vs 20+ questions)
           - 2.1.2.1. E-commerce: 5 focused questions
           - 2.1.2.2. SaaS: 6 focused questions  
           - 2.1.2.3. Blog/Corporate: 4 focused questions
           - 2.1.2.4. Mobile: 5 focused questions
           - 2.1.2.5. API: 4 focused questions
       - 2.1.3. **Auto-Completion with Context7**
           - 2.1.3.1. Tech Stack Suggestions (based on project type + scale)
           - 2.1.3.2. Current 2025 Trends Research
           - 2.1.3.3. User Accept/Modify/Reject Flow
       - 2.1.4. **Realistic Automatic Estimates**
           - 2.1.4.1. Market Rate Research via Context7
           - 2.1.4.2. Technology-Specific Adjustments
           - 2.1.4.3. Feature-Based Cost Breakdowns
           - 2.1.4.4. Team Size & Timeline Recommendations
       
   2.2. **Phase 2: Enhanced Task Generation** (`generate_tasks_guide.md`)
       - 2.2.1. **Automatic Complexity Determination**
           - 2.2.1.1. Simple: 10-15 tasks, $2K-$10K, 1-2 devs
           - 2.2.1.2. Medium: 15-25 tasks, $10K-$25K, 2-3 devs
           - 2.2.1.3. Complex: 25-40 tasks, $25K-$60K, 3-5 devs
           - 2.2.1.4. Enterprise: 40+ tasks, $60K+, 5+ devs
       - 2.2.2. **Context7 Validation & Research**
           - 2.2.2.1. Tech Stack Pattern Validation
           - 2.2.2.2. Current Best Practices Integration
           - 2.2.2.3. Industry-Specific Standards Check
       - 2.2.3. **Task Structure Enhancement**
           - 2.2.3.1. 8-40 hour granularity per task
           - 2.2.3.2. Cross-PRD consistency validation
           - 2.2.3.3. Technical feasibility validation

   2.3. **Phase 3: Iterative Quality Execution** (`execute_tasks_guide.md`)
       - 2.3.1. **Standard Implementation Phases** (1-5)
           - 2.3.1.1. Phase 1: Foundation & Setup
           - 2.3.1.2. Phase 2: Core Feature Development  
           - 2.3.1.3. Phase 3: Quality Assurance & Testing
           - 2.3.1.4. Phase 4: Deployment & Production
           - 2.3.1.5. Phase 5: Monitoring & Maintenance
       - 2.3.2. **Mandatory Iterative Quality Loop** (replaces single healing)
           - 2.3.2.1. Maximum 5 iterations until 8/10+ achieved
           - 2.3.2.2. Automatic improvement generation
           - 2.3.2.3. Context7-enhanced standards research
           - 2.3.2.4. Quality certification before completion

### 3. **QUALITY SYSTEM** (Iterative, MCP-powered)
   3.1. **UI/UX Iterative Quality System** (`ui_healing_guide.md`)
       - 3.1.1. **MCP Tool Requirements**
           - 3.1.1.1. MCP Playwright (automated browser testing)
           - 3.1.1.2. MCP Context7 (real-time research)
           - 3.1.1.3. Additional MCPs (web-scraper, lighthouse, accessibility)
       - 3.1.2. **6 Quality Dimensions** (ALL must be >= 8/10)
           - 3.1.2.1. **Visual Consistency** (20% weight)
               - Design system adherence
               - Component consistency analysis
               - Brand alignment assessment
           - 3.1.2.2. **CRO Optimization** (25% weight - highest)
               - CTA placement & effectiveness
               - Trust signal implementation
               - Conversion funnel analysis
           - 3.1.2.3. **Accessibility** (20% weight)
               - WCAG 2.1 compliance
               - Color contrast validation
               - Keyboard navigation testing
           - 3.1.2.4. **Architecture Quality** (15% weight)
               - Frontend architecture assessment
               - API design evaluation
               - Code organization analysis
           - 3.1.2.5. **Performance** (10% weight)
               - Lighthouse integration
               - Core Web Vitals measurement
               - Bundle optimization analysis
           - 3.1.2.6. **Responsive Design** (10% weight)
               - Multi-breakpoint testing
               - Touch target validation
               - Cross-device consistency
       - 3.1.3. **Iterative Improvement Loop**
           - 3.1.3.1. Enhanced analysis with Context7 research
           - 3.1.3.2. Score calculation with iteration weighting
           - 3.1.3.3. Threshold validation (8/10 requirement)
           - 3.1.3.4. Automatic improvement application
           - 3.1.3.5. Success/Manual review determination

### 4. **SUPPORTING SYSTEMS**
   4.1. **Standards & Patterns** (JSON Configuration)
       - 4.1.1. **UI Healing Standards** (`ui_healing_standards.json`)
           - Technical standards and scoring matrix
           - Quality thresholds and criteria
       - 4.1.2. **CRO Optimization Patterns** (`cro_optimization_patterns.json`)
           - 88 proven conversion optimization patterns
           - Industry-specific CRO implementations
   
   4.2. **Integration Layer**
       - 4.2.1. **MCP Context7 Integration**
           - Real-time best practices research
           - Market rate validation
           - Technology trend analysis
       - 4.2.2. **MCP Playwright Integration**
           - Automated visual analysis
           - Multi-breakpoint testing
           - Performance measurement

### 5. **OUTPUT ARTIFACTS** (Session-linked files)
   5.1. **Generated Documents**
       - 5.1.1. `01_prd_{session-id}_{project-name}.md` (Enhanced PRD)
       - 5.1.2. `02_tasks_{session-id}_{project-name}.md` (Validated tasks)
       - 5.1.3. `03_report_{session-id}_{project-name}.md` (Execution report)
       - 5.1.4. `03_quality_{session-id}_{project-name}.md` (Quality certification)
   
   5.2. **Quality Certification**
       - 5.2.1. Professional standards validation
       - 5.2.2. Production deployment approval
       - 5.2.3. Iteration history documentation

### 6. **EFFICIENCY METRICS** (Measurable improvements)
   6.1. **Time Reductions**
       - 6.1.1. PRD Creation: 15 min (was 45+ min) → 60% reduction
       - 6.1.2. Tech Decisions: 5 min (was 30+ min) → 83% reduction
       - 6.1.3. Quality Assurance: Automated (was manual) → 100% automation
   
   6.2. **Quality Improvements**
       - 6.2.1. 100% compliance with 8/10+ standard
       - 6.2.2. Professional certification for all projects
       - 6.2.3. Systematic quality validation before deployment

---

## 🎯 Best Practices for Claude

### Before Starting Any Project
1. **Always check** for existing sessions first
2. **Use smart questioning** - let the framework detect project type
3. **Trust auto-completion** - it's based on current market research
4. **Don't skip quality loop** - it ensures professional standards

### During PRD Creation
1. **Answer contextual questions** thoroughly but concisely
2. **Review tech stack suggestions** before accepting
3. **Validate estimates** against project scope
4. **Use Context7 research** for current trends

### During Task Generation
1. **Let Context7 validate** tech stack patterns
2. **Check complexity classification** is accurate
3. **Ensure cross-validation** with PRD passes
4. **Verify task granularity** (8-40 hours per task)

### During Execution
1. **Trust the iterative process** - let it run its course
2. **Don't bypass quality checks** - they prevent technical debt
3. **Document any manual interventions** needed
4. **Ensure quality certification** before declaring complete

### Before Any Code Changes
1. **Always explain first** - Provide short, concise explanation of what the change does
2. **State the purpose** - Why this change is needed or beneficial
3. **Describe the impact** - What will be different after the change
4. **Then implement** - Only proceed with code after explanation is given

---

## 🚨 Error Handling & Troubleshooting

### Common Issues
- **Session ID collisions:** Framework auto-resolves
- **Context7 research failures:** Graceful fallback to cached patterns
- **Quality loop timeout:** Manual improvement plan generated
- **MCP Playwright issues:** Verify installation and permissions

### Emergency Commands
```bash
# Reset session if corrupted
./ai-dev reset {session-id}

# Force manual quality review
./ai-dev heal {session-id} --manual

# Export session for debugging
./ai-dev export {session-id}
```

---

## 📈 Success Metrics

### Framework Efficiency
- **PRD Creation:** 15 minutes (was 45+ minutes)
- **Technical Decisions:** 5 minutes (was 30+ minutes)
- **Quality Achievement:** Automated (was manual)
- **Market Accuracy:** Real-time (was outdated)

### Quality Assurance
- **100% compliance** with 8/10+ standard
- **Professional certification** for all projects
- **Reduced technical debt** through iterative improvement
- **Enhanced user experience** through systematic optimization

---

## 🔮 Framework Roadmap

### Current Version (v3.1.1 Enhanced)
- ✅ Smart contextual questioning
- ✅ Context7 auto-completion
- ✅ Realistic market estimates
- ✅ Iterative quality loop
- ✅ MCP Playwright integration

### Future Enhancements
- 🔄 Multi-language project support
- 🔄 Advanced analytics integration
- 🔄 Team collaboration features
- 🔄 Industry-specific templates

---

## 💡 Tips for Maximum Efficiency

1. **Trust the automation** - the framework has been optimized for efficiency
2. **Use Context7 research** - it provides current, relevant information
3. **Let the quality loop run** - it ensures professional standards
4. **Follow the session workflow** - it maintains perfect traceability
5. **Document customizations** - for future reference and improvements

---

## 🔄 Framework Rules & Standards

### Critical Rules (ALWAYS follow)
1. **ALL documentation in English** - Never use other languages in files
2. **Session-based workflow** - Always maintain session traceability
3. **Quality threshold enforcement** - Never bypass 8/10 requirement
4. **Context7 integration** - Use real-time research for all decisions
5. **MCP Playwright validation** - Visual analysis is mandatory
6. **Explain before implementing** - Always provide short, concise explanation before proposing code changes

### Output Standards
- **File naming:** Follow exact pattern `{step}_{session-id}_{project-name}.md`
- **Language:** English only in all documentation and code
- **Quality:** Professional standards with certification
- **Traceability:** Perfect session linkage across all files

---

**Remember:** This framework is designed to deliver professional-quality results efficiently. Trust the process, use the automation, and focus on the creative and strategic aspects of development while the framework handles the systematic quality assurance.