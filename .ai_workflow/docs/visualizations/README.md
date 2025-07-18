# 🗺️ Framework Visualizations

This directory contains all the visual representations of the AI-Assisted Development Framework.

## 📊 Available Visualizations

### 🏗️ Architecture Diagrams
- **architecture.mmd** - Complete system architecture
- **data_flow.mmd** - Data flow and processing pipeline
- **components.svg** - Component relationships (generated)

### 🔄 Workflow Maps
- **workflow_map.mmd** - Complete workflow mind map
- **workflow_relationships.mmd** - Workflow dependencies
- **execution_flow.svg** - Workflow execution paths (generated)

### 🎮 Command References
- **commands.mmd** - Complete command reference
- **command_tree.svg** - Command hierarchy (generated)
- **usage_patterns.mmd** - Common usage patterns

### 🤖 GitHub Actions
- **github_actions.mmd** - Actions timeline and schedule
- **automation_flow.mmd** - Automation workflows
- **actions_dependencies.svg** - Action relationships (generated)

### 🎯 Interactive Dashboards
- **dashboard.html** - Real-time system dashboard
- **workflow_explorer.html** - Interactive workflow explorer
- **metrics_dashboard.html** - Performance metrics dashboard

## 🛠️ Tools Used

### Mermaid Diagrams
- **Installation**: `npm install -g @mermaid-js/mermaid-cli`
- **Usage**: `mmdc -i diagram.mmd -o diagram.svg`
- **Live Editor**: https://mermaid.live/

### Interactive HTML
- **Pure HTML/CSS/JS** - No external dependencies
- **Responsive Design** - Works on all devices
- **Real-time Updates** - Auto-refreshing metrics

### Command Line Tools
- **Graphviz**: For complex graph layouts
- **PlantUML**: For UML diagrams
- **D3.js**: For interactive visualizations

## 🚀 Quick Start

### View Diagrams
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Generate SVG from mermaid
mmdc -i diagrams/architecture.mmd -o diagrams/architecture.svg

# Open interactive dashboard
open interactive/dashboard.html
```

### Update Visualizations
```bash
# Run visualization generator
./.ai_workflow/scripts/generate_visualizations.sh

# Or use the framework command
./ai-dev generate-visualizations
```

## 📋 Visualization Types

### 1. **Mind Maps** 🧠
- Framework overview
- Workflow relationships
- Command structures
- Best for: Understanding relationships

### 2. **Flowcharts** 🔄
- Process flows
- Decision trees
- Execution paths
- Best for: Understanding processes

### 3. **Architecture Diagrams** 🏗️
- System components
- Data flows
- Integration points
- Best for: Understanding structure

### 4. **Timeline Charts** 📅
- GitHub Actions schedule
- Workflow execution
- Performance trends
- Best for: Understanding timing

### 5. **Interactive Dashboards** 🎯
- Real-time metrics
- System status
- User interfaces
- Best for: Monitoring and control

## 🎨 Customization

### Themes
- **Light Theme**: Default clean theme
- **Dark Theme**: Available for dashboards
- **High Contrast**: Accessibility focused

### Colors
- **Primary**: #1976d2 (Blue)
- **Secondary**: #388e3c (Green)
- **Accent**: #f57c00 (Orange)
- **Error**: #d32f2f (Red)

### Layouts
- **Responsive**: Adapts to screen size
- **Print-friendly**: Optimized for printing
- **Mobile-first**: Touch-friendly interfaces

## 📊 Metrics Tracked

### System Health
- Framework status
- Performance metrics
- Security scores
- Error rates

### Usage Analytics
- Command usage
- Workflow execution
- User activity
- Adoption rates

### Performance Data
- Response times
- Resource usage
- Bottlenecks
- Optimization opportunities

## 🔄 Auto-Generation

The visualization system automatically updates when:
- New workflows are added
- Commands are modified
- GitHub Actions are updated
- Documentation changes

### Triggers
- **Git commits**: Regenerate on changes
- **Scheduled**: Daily updates
- **Manual**: On-demand generation

## 🎯 Best Practices

### For Developers
1. **Keep diagrams updated** with code changes
2. **Use consistent styling** across visualizations
3. **Include legends** for complex diagrams
4. **Test interactive elements** on different devices

### For Users
1. **Start with overview** diagrams
2. **Use interactive dashboards** for monitoring
3. **Refer to command maps** for quick reference
4. **Check timeline charts** for scheduling

## 🔗 Related Resources

- [Framework Documentation](../FRAMEWORK_GUIDE.md)
- [Architecture Guide](../ARCHITECTURE.md)
- [Command Reference](../CLI_REFERENCE.md)
- [GitHub Actions Guide](../GITHUB_ACTIONS_GUIDE.md)

---

*Visualizations are automatically generated and updated by the Framework Visualization System*
