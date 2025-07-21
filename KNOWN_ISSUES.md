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

**Total Issues Discovered:** 7  
**Resolved Issues:** 3  
**Active Issues:** 4 (3 Critical)  
**Framework Reliability:** 43% → Critical tracking and compatibility gaps affecting framework completeness

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