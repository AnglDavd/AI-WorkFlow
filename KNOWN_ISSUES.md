# Known Issues & Error Memory System

**Framework Version:** v3.1.1 Enhanced  
**Last Updated:** 2025-01-20  
**Purpose:** Track bugs, errors, and lessons learned to prevent recurring issues

---

## 🎯 Error Memory System Overview

This file serves as the framework's memory system to:
- **Document bugs** encountered during real-world usage
- **Track solutions** and workarounds that worked
- **Prevent recurring** issues in future projects
- **Improve framework** reliability over time
- **Share knowledge** across all AI assistants using the framework

---

## 🔍 Known Issues (Discovered During Testing)

### **ISSUE-001: Missing Git/GitHub Backup Integration**
**Status:** ✅ RESOLVED  
**Discovered:** 2025-01-20 during Gemini CLI testing  
**Problem:** README.md promised "Automatic GitHub backup" but feature was not implemented  
**Symptoms:** 
- No Git configuration prompts during workflow
- No commit reminders from assistant
- Documentation inconsistent with actual behavior

**Solution Applied:**
- Added comprehensive Git Workflow Guidelines to FRAMEWORK.md
- Updated Critical Rules to enforce proactive commit reminders
- Created mandatory Git setup validation process

**Prevention:** Always validate documentation promises against actual code implementation

---

### **ISSUE-002: Assistant Not Reminding Commits**
**Status:** ✅ RESOLVED  
**Discovered:** 2025-01-20 during real-world testing  
**Problem:** AI assistants weren't proactively reminding users to commit progress  
**Symptoms:**
- PRD and task files generated without version control
- No session traceability in Git history
- Lost work potential due to no backups

**Solution Applied:**
- Added Rule #9: "Proactive commit reminders - ALWAYS remind user to commit after completing any file generation"
- Created specific commit timing requirements
- Defined conventional commit format with session-id traceability

**Prevention:** Include explicit behavioral rules for assistants in FRAMEWORK.md

---

### **ISSUE-003: Framework Name Confusion with AI Models**
**Status:** ✅ RESOLVED  
**Discovered:** 2025-01-20 when testing with Gemini CLI  
**Problem:** CLAUDE.md filename was confusing for non-Claude AI models  
**Symptoms:**
- Gemini users questioning if framework was Claude-specific
- Potential adoption barriers for other AI models

**Solution Applied:**
- Renamed CLAUDE.md to FRAMEWORK.md
- Updated all references in documentation
- Made framework truly AI-model agnostic

**Prevention:** Use generic naming conventions for cross-platform compatibility

---

## 🚨 Active Issues (Need Attention)

### **ISSUE-004: Pre-push Hook Conflicts**
**Status:** 🔄 INVESTIGATING  
**Discovered:** 2025-01-20 during repository maintenance  
**Problem:** Pre-push hooks failing with "precommit" command errors  
**Symptoms:**
- `git push` fails with hook validation errors
- Need to use `--no-verify` flag to push
- Complex validation system causing conflicts

**Current Workaround:** Use `git push --no-verify`  
**Investigation Status:** Analyzing hook complexity vs benefit  
**Next Steps:** Consider simplifying or removing complex hooks

---

### **ISSUE-005: AI Assistants Marking Incomplete Tasks as Complete**
**Status:** 🔄 CRITICAL - INVESTIGATING  
**Discovered:** 2025-01-20 during real-world Gemini CLI testing  
**Problem:** AI assistants mark tasks as "completed" when they couldn't actually finish them  
**Symptoms:**
- Tasks marked with [x] in execution report despite not being finished
- Assistant moves to next task without resolving blockers
- False progress reporting leading to broken project dependencies
- Accumulation of invisible technical debt
- Project quality degradation due to skipped requirements

**Root Causes Identified:**
- Lack of specific "Definition of Done" criteria for each task type
- No validation protocol before marking tasks complete
- Missing impediment reporting system for blocked tasks
- AI optimism bias toward reporting positive progress
- Ambiguous interpretation of "attempting" vs "completing"

**Current Impact:** HIGH - Compromises entire framework reliability  
**Investigation Status:** Developing multi-level validation system  
**Next Steps:** Implement DoD criteria, validation protocol, and impediment tracking

---

### **ISSUE-006: Gemini CLI Failing with Replace Command**
**Status:** 🔄 CRITICAL - ACTIVE  
**Discovered:** 2025-01-20 during real-world Gemini CLI testing  
**Problem:** Gemini consistently fails when using Claude Code's `replace` command  
**Symptoms:**
- `replace` command not recognized or executed properly by Gemini
- Gemini attempts to use replace but receives errors
- File editing operations fail due to replace command incompatibility
- Assistant cannot modify existing files effectively

**Root Causes Identified:**
- Gemini CLI may not support Claude Code's specific `replace` command syntax
- Different AI models may have different tool command interfaces
- Framework assumes universal tool compatibility across AI models
- Lack of alternative editing methods for non-Claude AI models

**Current Impact:** HIGH - Blocks file editing and project development  
**Workaround Needed:** Alternative file editing approach for Gemini  
**Investigation Status:** Need to identify Gemini-compatible editing methods  
**Next Steps:** Create AI-model-specific tool usage guidelines

---

### **ISSUE-007: Missing Healing/Quality Stages in Execution Report**
**Status:** 🔄 CRITICAL - ACTIVE  
**Discovered:** 2025-01-20 during execution report review  
**Problem:** Execution report doesn't track the mandatory healing/quality loop process  
**Symptoms:**
- 03_report file only shows development phases (1-5) 
- No tracking of iterative quality improvement loop
- Missing healing validation steps and scores
- No record of quality certification process
- Incomplete project completion documentation

**Root Causes Identified:**
- Execution tracking system only considers development phases
- Framework promises iterative quality loop but doesn't track it
- Missing Phase 6: Mandatory healing/quality validation
- No integration between execution report and quality certification
- Gap between 03_report and 03_quality files

**Current Impact:** HIGH - Incomplete project tracking and quality oversight  
**Investigation Status:** Need to add healing phases to execution tracking  
**Next Steps:** Integrate quality loop tracking into execution report system

---

### **ISSUE-008: AI Assistant Creates Impediment Reports But Doesn't Resolve Issues**
**Status:** 🔄 CRITICAL - ACTIVE  
**Discovered:** 2025-01-20 during real-world Gemini CLI testing  
**Problem:** AI assistant properly documents impediments but fails to follow through with resolution attempts  
**Symptoms:**
- Impediment reports created correctly following protocol
- Issues documented with proper format and analysis
- Assistant moves on without attempting resolution
- Blocked tasks remain blocked indefinitely
- No systematic approach to resolving documented problems
- Project progress stalls due to unresolved impediments

**Root Causes Identified:**
- Lack of mandatory resolution protocol after impediment creation
- Missing follow-through enforcement in assistant behavior
- No escalation path for impediments requiring external help
- Gap between "reporting" and "resolving" responsibilities
- Assistant treats impediment reporting as completion rather than first step
- No time-bound resolution requirements

**Current Impact:** HIGH - Projects get stuck permanently on solvable issues  
**Investigation Status:** Need mandatory resolution protocol with follow-through  
**Next Steps:** Create resolution tracking and escalation system

---

### **ISSUE-009: Vague UI/UX Task Definitions - Lacking Detail and Depth**
**Status:** 🔄 CRITICAL - ACTIVE  
**Discovered:** 2025-01-20 during real-world project execution review  
**Problem:** UI/UX design tasks are defined too broadly and lack specific, actionable details  
**Symptoms:**
- Tasks like "Design homepage" or "Create user interface" without specifics
- No detailed breakdown of UI components, interactions, or design systems
- Missing specific deliverables: wireframes, mockups, component specs
- No guidance on design patterns, accessibility requirements, or responsive behavior
- Vague acceptance criteria that don't ensure quality design outcomes
- Assistant struggles to implement proper UI/UX without detailed specifications

**Root Causes Identified:**
- Task generation treats UI/UX as single monolithic activities
- Framework lacks UI/UX-specific task breakdown templates
- Missing design methodology integration (Design Systems, Atomic Design, etc.)
- No specification of design deliverables and artifacts
- Insufficient detail on user experience flow and interaction design
- Lack of component-level granularity in UI tasks

**Current Impact:** HIGH - Results in poor UI/UX quality and incomplete design implementation  
**Investigation Status:** Need detailed UI/UX task breakdown methodology  
**Next Steps:** Create comprehensive UI/UX task specification system with design deliverables

---

### **ISSUE-010: AI Not Using Playwright for Visual Analysis and Quality Scoring**
**Status:** 🔄 CRITICAL - ACTIVE  
**Discovered:** 2025-01-20 during quality loop execution review  
**Problem:** AI assistants are not actually using MCP Playwright for visual analysis and quality scoring system  
**Symptoms:**
- Quality scores provided without actual Playwright visual analysis
- No screenshots or visual evidence of quality assessment
- 6-dimension scoring system not being executed properly
- AI making subjective quality judgments instead of systematic analysis
- Missing iterative improvement loop with actual visual validation
- No use of browser automation for responsive testing and accessibility checks

**Root Causes Identified:**
- AI assistants don't know HOW to use Playwright effectively for quality analysis
- Missing specific instructions for Playwright integration workflow
- No mandatory Playwright usage enforcement in quality phase
- Framework assumes AI will use Playwright but provides no guidance
- Lack of step-by-step Playwright analysis protocol
- No validation that Playwright was actually used vs just claimed

**Current Impact:** HIGH - Quality certification is unreliable without actual visual analysis  
**Investigation Status:** Need mandatory Playwright usage protocol with verification  
**Next Steps:** Create detailed Playwright integration workflow and enforcement

---

## 📝 Error Reporting Template

When discovering new issues, use this format:

### **ISSUE-XXX: [Brief Description]**
**Status:** 🔄 INVESTIGATING / ✅ RESOLVED / ❌ BLOCKED  
**Discovered:** [Date] during [Context/Testing Scenario]  
**Problem:** [Detailed description of the issue]  
**Symptoms:**
- [Symptom 1]
- [Symptom 2]
- [Symptom 3]

**Solution Applied:** [What was done to fix it]  
**Prevention:** [How to avoid this in the future]

---

## 🔄 Error Memory Guidelines for AI Assistants

### **Always Check This File First**
Before starting any framework operation:
1. **Read KNOWN_ISSUES.md** to understand current limitations
2. **Apply known solutions** for recognized problems
3. **Watch for symptoms** of documented issues
4. **Document new issues** using the template above

### **Proactive Error Prevention**
1. **Validate assumptions** - Don't assume features work as documented
2. **Test critical paths** - Verify Git, MCP tools, file permissions
3. **Cross-reference documentation** - Ensure promises match implementation
4. **Update memory** - Add new issues immediately when discovered

### **Learning from Errors**
1. **Analyze root causes** - Why did this happen?
2. **Identify patterns** - Are there systemic issues?
3. **Improve documentation** - Update FRAMEWORK.md with lessons learned
4. **Share knowledge** - Make solutions accessible to all users

---

## 📊 Issue Statistics

**Total Issues Discovered:** 10  
**Resolved Issues:** 3  
**Active Issues:** 7 (6 Critical)  
**Framework Reliability:** 30% → Critical quality validation issues - framework not executing core features

---

## 🔮 Future Improvements

### **Planned Error Prevention Features**
- **Automated issue detection** during framework execution
- **Real-time validation** of promised features
- **Cross-platform testing** protocols
- **User feedback integration** system

### **Memory System Enhancements**
- **Issue categorization** by severity and impact
- **Solution effectiveness** tracking
- **Prevention success** metrics
- **Knowledge base** searchability

---

## 💡 Contributing to Error Memory

### **For Users:**
- Report new issues using the template
- Share workarounds that work
- Update resolution status when fixed
- Provide context about usage scenarios

### **For Developers:**
- Review this file before making changes
- Test against known issue scenarios
- Update status when implementing fixes
- Add prevention measures to avoid regressions

---

**Remember:** Every error is an opportunity to make the framework more robust. This memory system ensures we learn from mistakes and continuously improve the user experience.