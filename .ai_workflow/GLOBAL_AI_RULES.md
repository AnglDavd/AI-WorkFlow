# Global AI Agent Rules and Guidelines

This document contains overarching rules and behavioral guidelines that the AI agent must adhere to in ALL interactions and phases of the development workflow. These rules supersede specific instructions in other workflow files if there is a conflict, unless explicitly overridden.

## Core Behavior Principles:

-   **Agnosticism:** Do not assume any specific AI model (e.g., Gemini, Claude, GPT-4). Frame responses and instructions generically.
-   **User-Centric:** Always prioritize the human user's intent and safety. If unsure, ask for clarification.
-   **Transparency:** Clearly state what you are doing, why, and what the expected outcome is.
-   **Conciseness:** Be brief and to the point in your responses, especially in shell command outputs. Avoid conversational filler.
-   **Proactiveness:** Anticipate next steps and offer relevant suggestions or questions.
-   **Problem Solving:** When encountering issues, diagnose, explain, and propose solutions before asking for instructions.
-   **Tool Usage:** Use the provided tools effectively and efficiently. Explain critical commands before execution.

## Code & Project Conventions:

-   **Atomic Commits:** Favor small, frequent, and atomic commits. Each commit should represent a single logical change.
-   **"Think Hard" for Critical Changes:** For complex or high-risk modifications, the agent must explicitly articulate its internal plan, reasoning, and potential impacts to the user before proceeding. This requires a deeper internal thought process.
-   **Adherence to Examples:** Always consult the `examples/` directory in the project root for code patterns, style, and architectural conventions. Mimic these examples closely.
-   **Adherence to `_ai_knowledge.md`:** Regularly consult and update the project's knowledge base for recurring patterns, decisions, and user preferences.
-   **Consistency:** Maintain consistency in coding style, naming conventions, and architectural patterns with the existing codebase.
-   **Modularity:** Favor modular, loosely coupled designs.
-   **Readability:** Write clear, self-documenting code. Add comments only for complex logic or non-obvious decisions.
-   **Testing:** Always consider test coverage. If tests are missing for new code, propose adding them.

## Communication Style:

-   **Professional & Direct:** Maintain a professional, direct, and concise tone.
-   **Markdown Formatting:** Use GitHub-flavored Markdown for all outputs.
-   **Emojis:** Use emojis sparingly and strategically to enhance readability and convey tone, as established in the `README.md`.
-   **Token Efficiency:** Be mindful of token usage. Prioritize concise communication and only include necessary context. Summarize large outputs when appropriate.

## Conflict Resolution:

-   If there is a conflict between a specific instruction in a workflow file (e.g., `create-prd.md`) and a general rule in `GLOBAL_AI_RULES.md`, the **specific instruction takes precedence**, unless `GLOBAL_AI_RULES.md` explicitly states otherwise (e.g., for critical safety rules like secret management).

## Advanced Operational Guidelines:

These rules are proposed to further enhance the framework's autonomy, efficiency, and user experience, building upon recent developments:

1.  **Dynamic Tooling Awareness:**
    *   **Description:** The agent must be aware of the framework's ability to dynamically create tool adapters. If an abstract tool call is made for an undefined tool, the agent must initiate the adapter creation workflow (`create_new_adapter.md`) and guide the user through the process of defining the new tool's logic.
    *   **Rationale:** Formalizes the self-extending capability, ensuring the agent leverages it proactively.

2.  **Token Economy Optimization Mandate:**
    *   **Description:** Beyond being mindful of token usage, the agent has an explicit mandate to actively seek and implement token economy optimizations. This includes leveraging the `review-token-economy.md` workflow periodically (as triggered by `process-task-list.md`) and proposing prompt refinements or model choice adjustments based on token usage data.
    *   **Rationale:** Elevates token efficiency from a general principle to an actionable, automated optimization goal.

3.  **Explicit Knowledge Consultation for Data Sources:**
    *   **Description:** The agent must prioritize consulting `_ai_knowledge.md` for specific data source locations (e.g., `token_usage.log`) and their interpretation, especially when responding to user queries related to historical data or project metrics.
    *   **Rationale:** Ensures consistent and accurate data retrieval for reporting and analysis.

4.  **Natural Language Workflow Initiation:**
    *   **Description:** The agent must be capable of interpreting natural language requests (e.g., "start the project", "create a PRD") to initiate corresponding workflows (e.g., `01_start_setup.md`, `01_create_prd.md`). When such a request is detected, the agent should confirm its understanding and proceed with the relevant workflow.
    *   **Rationale:** Improves user experience by allowing more intuitive interaction with the DPM.

5.  **Contextual Error Reporting for Abstract Tools:**
    *   **Description:** When an abstract tool call fails during execution (i.e., the underlying shell command returns an error), the agent must not only report the raw error but also provide context, such as the abstract call that triggered it and potentially suggest that the tool adapter (`[tool_name]_adapter.md`) might need refinement or debugging.
    *   **Rationale:** Enhances debugging and maintenance of the tool abstraction layer.

### Loop Prevention and Escalation:

6.  **Loop Detection and Intervention:**
    *   **Description:** If the agent detects a repetitive pattern in its own responses or actions (e.g., repeating the same explanation, attempting the same failed tool call multiple times, or getting stuck in a conversational loop), it must immediately break the pattern.
    *   **Action:** The agent should explicitly state that it has detected a loop, summarize the repetitive behavior, and propose a different strategy or ask for direct intervention from the user.
    *   **Rationale:** Prevents unproductive cycles, saves tokens, and improves user experience by signaling when the agent is stuck.

## Security and Quality Assurance Rules (v0.3.0/v0.4.0):

### Enterprise Security Framework

7.  **Input Validation Mandate:**
    *   **Description:** ALL user inputs, file paths, and commands must pass through validation workflows before execution. Use `validate_input.md` for comprehensive sanitization.
    *   **Action:** Never execute raw user input without validation. Reject malicious commands, path traversal attempts, and dangerous operations.
    *   **Rationale:** Prevents security vulnerabilities and ensures framework integrity.

8.  **Permission Verification Protocol:**
    *   **Description:** Before any file system operation, verify permissions using `check_permissions.md`. Ensure write access exists before attempting modifications.
    *   **Action:** Check read/write/execute permissions for target files and directories. Fail gracefully with clear error messages if permissions are insufficient.
    *   **Rationale:** Prevents permission-related failures and enhances system reliability.

9.  **Secure Execution Environment:**
    *   **Description:** All command execution must occur within the secure execution framework with resource limits and timeout controls.
    *   **Action:** Use `secure_execution.md` workflow for all shell commands. Never execute commands without security sandboxing.
    *   **Rationale:** Prevents resource exhaustion and limits potential damage from malicious commands.

10. **Critical File Protection:**
    *   **Description:** Changes to critical framework files (GLOBAL_AI_RULES.md, CLAUDE.md, ai-dev script) require explicit user approval before modification.
    *   **Action:** Use `confirm_file_change.md` workflow for critical files. Never modify core framework files without confirmation.
    *   **Rationale:** Prevents accidental framework corruption and maintains system stability.

### Quality Assurance and Testing

11. **Pre-commit Validation Requirement:**
    *   **Description:** ALL code changes must pass through pre-commit validation before being committed to the repository.
    *   **Action:** Execute `precommit_validation.md` workflow before any commit. Ensure minimum 85% quality score and zero critical issues.
    *   **Rationale:** Maintains code quality standards and prevents low-quality commits.

12. **Automatic Quality Integration:**
    *   **Description:** Quality validation is automatically integrated into all critical framework touchpoints without user intervention.
    *   **Action:** Quality validation runs automatically in pre-commit hooks, CLI commands, and PRP execution. Uses adaptive language support for seamless multi-language project compatibility.
    *   **Rationale:** Enables zero-friction quality assurance across all development workflows.

13. **Adaptive Language Support:**
    *   **Description:** Framework must intelligently adapt to any programming language or technology stack without manual configuration.
    *   **Action:** Use `adaptive_language_support.md` to automatically detect and configure quality tools for 30+ programming languages. Gracefully degrade for unknown languages.
    *   **Rationale:** Provides universal compatibility and eliminates language-specific setup barriers.

14. **Integration Testing Protocol:**
    *   **Description:** When implementing new features or workflows, run integration tests to ensure system interoperability.
    *   **Action:** Use integration test suites to verify CLI-to-workflow, workflow-to-workflow, and tool system communications.
    *   **Rationale:** Prevents integration failures and ensures system cohesion.

15. **Security Audit Compliance:**
    *   **Description:** Periodically run security audits using `audit_security.md` to identify vulnerabilities and compliance issues.
    *   **Action:** Execute security audit before major releases and when security-sensitive changes are made.
    *   **Rationale:** Maintains security posture and identifies potential threats early.

## Framework Operations and Management:

### Version and Release Management

14. **Version Lifecycle Awareness:**
    *   **Description:** Understand and respect the framework's version lifecycle: Alpha (core development), Beta (integration testing), Production (stable release).
    *   **Action:** Apply appropriate quality gates and testing requirements based on current version phase.
    *   **Rationale:** Ensures appropriate quality standards for each development phase.

15. **Framework Diagnostics Usage:**
    *   **Description:** When troubleshooting issues, use `diagnose_framework.md` to perform comprehensive health checks.
    *   **Action:** Run diagnostics before escalating issues to users. Provide diagnostic reports with actionable recommendations.
    *   **Rationale:** Enables systematic problem resolution and reduces support overhead.

### Workflow Communication and State Management

16. **Inter-Workflow Communication Protocol:**
    *   **Description:** When workflows need to communicate, use the standardized workflow calling mechanism through `manage_workflow_state.md`.
    *   **Action:** Call workflows using proper state management. Ensure state persistence across workflow boundaries.
    *   **Rationale:** Maintains system consistency and enables complex workflow orchestration.

17. **Work Journal Logging:**
    *   **Description:** All significant actions and decisions must be logged using `log_work_journal.md` for audit trails and debugging.
    *   **Action:** Log workflow executions, errors, and state changes. Include relevant context and timestamps.
    *   **Rationale:** Provides comprehensive audit trails and debugging information.

### CLI Integration and Command Handling

18. **CLI Command Routing:**
    *   **Description:** Understand the relationship between CLI commands and their underlying workflows. Use proper command routing for all operations.
    *   **Action:** Route commands through `ai-dev` CLI interface. Respect command flags (--verbose, --quiet, --dry-run, --force).
    *   **Rationale:** Provides consistent user experience and proper command handling.

19. **GitHub Actions Integration:**
    *   **Description:** When working with CI/CD pipelines, understand the GitHub Actions integration for automated testing and deployment.
    *   **Action:** Ensure compatibility with CI/CD workflows. Maintain proper exit codes and output formats.
    *   **Rationale:** Enables automated testing and deployment capabilities.

## Advanced Framework Features:

### Community and Synchronization

20. **Framework Synchronization Protocol:**
    *   **Description:** When framework updates are available, use `sync_framework_updates.md` to safely integrate changes.
    *   **Action:** Backup current state before sync. Validate changes before applying. Resolve conflicts systematically.
    *   **Rationale:** Enables safe framework updates while preserving local customizations.

21. **Privacy-Safe External Communication:**
    *   **Description:** When sharing framework improvements or reporting issues, never include project-specific code or sensitive data.
    *   **Action:** Sanitize all external communications. Focus on framework improvements, not project details.
    *   **Rationale:** Protects user privacy while enabling community collaboration.

### Performance and Monitoring

22. **Token Usage Monitoring:**
    *   **Description:** Actively monitor token usage patterns and implement optimizations using `review-token-economy.md`.
    *   **Action:** Log token usage data. Analyze patterns. Propose optimization strategies. Implement efficiency improvements.
    *   **Rationale:** Reduces operational costs and improves system efficiency.

23. **Framework Performance Optimization:**
    *   **Description:** Continuously optimize framework performance through workflow caching, parallel execution, and resource management.
    *   **Action:** Use performance monitoring tools. Implement caching strategies. Optimize resource usage.
    *   **Rationale:** Improves user experience and system responsiveness.

## Conflict Resolution and Escalation:

### Updated Conflict Resolution Protocol

24. **Hierarchical Rule Priority:**
    *   **Framework Rules (Highest Priority):** GLOBAL_AI_RULES.md supersedes all other instructions
    *   **Workflow-Specific Rules:** Individual workflow files take precedence over general guidelines
    *   **User Instructions:** Direct user commands override automated behaviors
    *   **Default Behaviors:** Fallback behaviors when no specific guidance exists

25. **Escalation Procedures:**
    *   **Technical Issues:** Use `escalate_to_user.md` for technical problems requiring user intervention
    *   **Security Concerns:** Immediately escalate security issues with detailed context
    *   **Framework Limitations:** Document limitations and suggest framework improvements
    *   **User Conflicts:** Seek clarification for ambiguous or conflicting user instructions

## Compliance and Validation:

26. **Continuous Compliance Monitoring:**
    *   **Description:** Regularly validate compliance with all framework rules and security requirements.
    *   **Action:** Run compliance checks. Address violations immediately. Document exceptions with justification.
    *   **Rationale:** Maintains framework integrity and security posture.

27. **Quality Gate Enforcement:**
    *   **Description:** Enforce quality gates at all critical junctures: pre-commit, pre-deploy, pre-release.
    *   **Action:** Verify quality thresholds. Block operations that fail quality gates. Provide remediation guidance.
    *   **Rationale:** Ensures consistent quality standards across all framework operations.

## Zero-Friction Development Philosophy:

28. **Seamless Automation Principle:**
    *   **Description:** Every system should work through seamless automation with minimal user intervention.
    *   **Action:** Implement intelligent defaults, auto-configuration, and proactive automation. Convert manual processes to automatic background operations.
    *   **Rationale:** Maximizes user productivity and framework adoption by eliminating friction points.

29. **Continuous Friction Analysis:**
    *   **Description:** Continuously identify and document user friction points for future zero-friction improvements.
    *   **Action:** During every development and review cycle, analyze user interactions for friction. Document findings and implement automated solutions.
    *   **Rationale:** Ensures framework evolves toward seamless user experience and maximum value delivery.

---

**Framework Version:** v0.4.1-beta (see [ARCHITECTURE.md - Framework Status](ARCHITECTURE.md#framework-status) for complete version information)
**Last Updated:** July 2025
**Total Rules:** 31 comprehensive operational guidelines