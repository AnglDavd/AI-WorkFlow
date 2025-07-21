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

**Total Issues Discovered:** 4  
**Resolved Issues:** 3  
**Active Issues:** 1  
**Framework Reliability:** 75% → Improving with each discovery

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