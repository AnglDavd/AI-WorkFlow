# 🚀 AI Development Framework

[![Version](https://img.shields.io/badge/version-v3.1.1-success.svg)](https://github.com/AnglDavd/AI-WorkFlow/releases)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)

**Transform your ideas into complete development plans in minutes, not hours.**

---

## 🎯 What does this do?

**You give it an idea:** "I want an online store for handcrafted products"

**It gives you back:**
- ✅ Professional technical specifications
- ✅ Complete task breakdown with estimates
- ✅ Quality-certified development plan
- ✅ Everything needed to build your project

**Time:** 15-30 minutes total (was hours of work)

---

## 🚀 How to use it

### Step 1: Setup
```bash
# Download the framework
git clone https://github.com/AnglDavd/AI-WorkFlow.git
cd AI-WorkFlow

# Make it executable
chmod +x ai-dev
```

### Step 2: Create your project plan
```bash
# Start the smart interview process
./ai-dev create
```
**What happens:** Answer 6-8 questions about your project. The AI will detect your project type and ask only relevant questions.

**Result:** `01_prd_{session-id}_{project-name}.md` - Your professional project specification

### Step 3: Generate development tasks
```bash
# Generate tasks from your PRD
./ai-dev generate 01_prd_{session-id}_{project-name}.md
```
**What happens:** AI breaks down your project into specific, actionable tasks with time estimates.

**Result:** `02_tasks_{session-id}_{project-name}.md` - Your complete task list

### Step 4: Execute with quality tracking
```bash
# Execute the development plan
./ai-dev execute 02_tasks_{session-id}_{project-name}.md
```
**What happens:** AI works through each task, tracks progress, and ensures quality standards (8/10+) before completion.

**Result:** Working project + quality certification

---

## 📁 What files do you get?

```
01_prd_{session-id}_{project-name}.md      # Project specifications
02_tasks_{session-id}_{project-name}.md    # Task breakdown  
03_report_{session-id}_{project-name}.md   # Progress tracking
03_quality_{session-id}_{project-name}.md  # Quality certification
```

---

## 🤖 AI Model Compatibility

### Works with:
- ✅ **Claude Code** - Full feature support
- ✅ **Gemini CLI** - Compatible with workarounds
- ✅ **Other AI models** - Basic compatibility

### Required for enhanced features:
```bash
# Install MCP tools (optional but recommended)
claude mcp add playwright npx '@playwright/mcp@latest'
claude mcp add context7  # For real-time research
```

---

## 💡 Key Features

- **Smart questioning** - Project type detection, focused questions
- **Quality guaranteed** - 8/10+ certification required before completion  
- **Progress tracking** - Real-time task completion monitoring
- **Error learning** - Framework improves from each project
- **Cross-platform** - Works with multiple AI models

---

## 🔧 Quick Start Example

```bash
# 1. Get the framework
git clone https://github.com/AnglDavd/AI-WorkFlow.git
cd AI-WorkFlow
chmod +x ai-dev

# 2. Create your first project
./ai-dev create
# Answer the questions about your project idea

# 3. Generate the development plan
./ai-dev generate 01_prd_123456_my-project.md

# 4. Execute with quality tracking
./ai-dev execute 02_tasks_123456_my-project.md
```

**That's it!** You'll have a complete, quality-certified development plan.

---

## 🆘 Need Help?

### Common Commands
```bash
./ai-dev --help              # Show all commands
./ai-dev list                # List all your projects  
./ai-dev status {session-id} # Check project status
```

### Framework Files
- **FRAMEWORK.md** - Complete rules and guidelines for AI assistants
- **KNOWN_ISSUES.md** - Known bugs and solutions
- **ai-dev** - Main CLI tool

---

## 📊 Project Examples

| Project Type | Questions | Time | Output |
|--------------|-----------|------|--------|
| E-commerce Store | 5 focused | 15 min | 20-30 tasks, $12K estimate |
| SaaS Platform | 6 focused | 20 min | 35-45 tasks, $28K estimate |
| Mobile App | 5 focused | 15 min | 25-35 tasks, $18K estimate |

---

## 🔮 What makes this different?

1. **Actually fast** - 15-30 minutes vs hours of manual work
2. **Quality enforced** - Can't complete without 8/10+ certification
3. **Learns from mistakes** - Error memory system improves over time
4. **Cross-platform** - Works with different AI models
5. **Battle-tested** - Refined through real-world usage

---

## 📄 License

GPL-3.0 - Free and open source

**Created by:** AnglDavd with Claude Code  
**Problems?** Open an issue on GitHub