# Cost and Token Monitoring Integration Proposal

## 1. Introduction

This document outlines a proposal for integrating cost and token monitoring into the DPM framework. The goal is to provide users with transparency into their LLM usage and associated costs. This proposal is based on research into the APIs of major LLM providers (OpenAI, Anthropic, Google) and considers the current limitations of the framework.

## 2. Key Findings from Research

All major LLM providers return token consumption data in their API responses, but the naming conventions differ:

-   **OpenAI:** `usage` object with `prompt_tokens`, `completion_tokens`, `total_tokens`.
-   **Anthropic:** `usage` object with `input_tokens`, `output_tokens`.
-   **Google (Gemini):** `usage_metadata` object with `prompt_token_count`, `candidates_token_count`, `total_token_count`.

Despite the different names, the underlying data is consistent: a count of tokens used for input and tokens generated for output.

## 3. Proposed Unified Data Structure

To handle these differences, we propose a standardized, provider-agnostic data structure to be used internally within the framework. This structure would be stored in a dedicated log file, e.g., `/.ai_workflow/work_journal/token_usage.log`.

Each entry in the log would be a JSON object with the following format:

```json
{
  "timestamp": "YYYY-MM-DDTHH:MM:SSZ",
  "model_provider": "openai | anthropic | google | etc.",
  "model_name": "gpt-4 | claude-3-opus | gemini-1.5-pro | etc.",
  "input_tokens": 1234,
  "output_tokens": 5678,
  "total_tokens": 6912,
  "estimated_cost_usd": 0.01234 // Optional, if cost data is available
}
```

## 4. Conceptual Workflow for Data Capture

Since the agent cannot directly make API calls and intercept the responses, the data capture process would rely on the user or another external tool providing the necessary information.

Here is a conceptual workflow:

1.  **User/Tool makes LLM API call.**
2.  **User/Tool extracts the `usage` object** from the API response.
3.  **User/Tool invokes a DPM workflow** to log the data, e.g., `/.ai_workflow/workflows/monitoring/log_token_usage.md`.
4.  **The `log_token_usage.md` workflow** would take the provider, model name, input tokens, and output tokens as arguments.
5.  **The workflow formats the data** into the unified JSON structure and appends it to `token_usage.log`.

## 5. Reporting

The `FRAMEWORK_ASSISTANT` can be tasked with reading `token_usage.log`, aggregating the data, and generating a summary report. This report could be a simple Markdown table or be used to generate an HTML visualization (similar to the existing `generate_status_html.md` workflow).

## 6. Challenges and Limitations

-   **API Key Management:** The framework itself cannot securely store or use API keys. This is a major blocker for a fully automated implementation.
-   **Cost Calculation:** Costs per token vary significantly between models and providers, and can change over time. Maintaining an accurate, up-to-date cost calculation mechanism would be complex. The `estimated_cost_usd` field is therefore optional and would rely on a best-effort calculation.
-   **Manual Intervention:** The proposed workflow relies on manual steps from the user or an external script to feed the data into the framework. A fully automated solution is not feasible with the current toolset.

## 7. Prototype Implementation (Next Step)

As a next step, we can implement a "placeholder" prototype:

1.  Create the `/.ai_workflow/workflows/monitoring/` directory.
2.  Create the `log_token_usage.md` workflow. This workflow will take token data as input and append it to the log file.
3.  Create a sample `token_usage.log` file with a few entries to demonstrate the format.
4.  Create a `generate_cost_report.md` workflow that reads the log and generates a summary.

This prototype will demonstrate the viability of the system and provide a clear path for a more complete integration if the API access limitation is addressed in the future.
