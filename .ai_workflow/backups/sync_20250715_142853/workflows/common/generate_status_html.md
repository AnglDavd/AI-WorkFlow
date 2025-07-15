## Objective
This node generates a simple HTML visualization of the project's progress and status, incorporating data from `progress_report.md` and `_project.md`.

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Generate Status HTML workflow."

PROGRESS_REPORT_CONTENT=$(cat ./.ai_workflow/progress_report.md)
PROJECT_MD_CONTENT=$(cat ./.ai_workflow/_project.md)

# Extract task data for Mermaid Gantt chart (simplified example)
# This assumes a format like: "- Task ID: [ID] - Description: [Desc]"
# For a real Gantt chart, more structured data would be needed.
# For now, we'll just display the task list as text.

HTML_CONTENT="<html lang=\"en\"><head><meta charset=\"UTF-8\"><title>Project Status Report</title><script src=\"https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js\"></script><style>body { font-family: sans-serif; margin: 20px; } pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; }</style></head><body><h1>Project Status Overview</h1><h2>Project Details</h2><pre>${PROJECT_MD_CONTENT}</pre><h2>Progress Report</h2><pre>${PROGRESS_REPORT_CONTENT}</pre><h2>Task Progress (Mermaid Gantt - Conceptual)</h2><div class=\"mermaid\">\n  gantt\n    dateFormat  YYYY-MM-DD\n    title Project Tasks Overview\n    section Planning\n      Initial Setup :a1, 2025-07-01, 3d\n    section Development\n      Feature A :a2, after a1, 5d\n      Feature B :a3, after a2, 7d\n    section Testing\n      Testing Phase :a4, after a3, 4d\n</div></body></html>"

echo "$HTML_CONTENT" > ./.ai_workflow/temp_status_report.html

echo "HTML status report generated: ./.ai_workflow/temp_status_report.html"
echo "Please open this file in your web browser to view the report."

if [ $? -ne 0 ]; then
    ./.ai_workflow/workflows/common/error.md "Failed to generate status HTML."
    exit 1
fi
```

## Verification Criteria
The command should exit with 0, and a new HTML file `temp_status_report.html` should be created in the `.ai_workflow/` directory.

## Next Steps
- This is a terminal node for visualization. The user will manually open the generated HTML file.
