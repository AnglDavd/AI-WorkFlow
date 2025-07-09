# Review and Optimize Token Economy

## Goal
To analyze the project's token consumption patterns and identify opportunities to improve token economy without significantly compromising the quality of the output.

## Role
You are a Senior AI Engineer specializing in prompt engineering and cost optimization. Your task is to act as a consultant, analyzing historical usage data and suggesting concrete, actionable improvements.

## Execution Flow

1.  **Analyze Token Usage Data:**
    -   Read and parse the entire `/.ai_workflow/work_journal/token_usage.log` file.
    -   This is your primary data source. Do not proceed without it.

2.  **Identify High-Consumption Patterns:**
    -   Aggregate the data to find which workflows, prompts, or models are responsible for the highest token consumption.
    -   Pay special attention to:
        -   **High Input Tokens:** Prompts that are consistently very long.
        -   **High Output Tokens:** Tasks that generate verbose or unnecessarily large outputs.
        -   **Expensive Models:** Workflows that frequently use top-tier, expensive models (e.g., `gpt-4`, `claude-3-opus`).

3.  **Correlate Usage with Prompts:**
    -   For the top 1-3 highest-consuming patterns, identify the specific `.md` prompt files that are driving them. For example, if you find that calls using the `FRAMEWORK_ASSISTANT` are expensive, you should analyze `FRAMEWORK_ASSISTANT.md`.

4.  **Analyze Prompts for Inefficiencies:**
    -   Read the content of the identified prompt files.
    -   Look for the following optimization opportunities:
        -   **Verbosity:** Can the instructions be made more concise and direct?
        -   **Redundancy:** Are there repeated instructions or examples?
        -   **Example Size:** Are the few-shot examples in the prompt overly long? Can they be shortened while retaining their instructional value?
        -   **Model Choice:** Is a top-tier model necessary for this task, or could a smaller, faster, cheaper model suffice?

5.  **Generate an Optimization Report:**
    -   Create a report in Markdown format.
    -   The report must be structured, actionable, and data-driven.
    -   For each suggested optimization, provide:
        -   **The Finding:** A brief, data-supported description of the issue (e.g., "The `create-prd.md` prompt has an average input token count of 3500, making it the most expensive prompt in the project.").
        -   **The Analysis:** A short explanation of *why* it's inefficient (e.g., "The prompt contains three very long, complete examples of a PRD.").
        -   **The Recommendation:** A concrete, specific suggestion for improvement (e.g., "Shorten the examples in `create-prd.md` to only include the most critical sections, or replace one of them with a more concise summary.").

## Final Output
-   A Markdown report containing the analysis and a list of actionable recommendations for improving token economy.
