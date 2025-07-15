# Generate Cost and Token Usage Report

## Objective
To read the `token_usage.log` file, aggregate the data, and present a clear, human-readable summary of token consumption.

## Role
You are a data analyst. Your job is to process a log file, perform calculations, and format the output in a structured and easy-to-understand report.

## Execution Flow

1.  **Read the Log File:**
    -   Read the entire content of `/.ai_workflow/work_journal/token_usage.log`.

2.  **Process the Data:**
    -   The file contains one JSON object per line. Parse each line into a structured object.
    -   Calculate the following aggregate metrics:
        -   Total requests (i.e., number of lines).
        -   Total input tokens across all requests.
        -   Total output tokens across all requests.
        -   Grand total of all tokens.
        -   A breakdown of total tokens per model provider (e.g., total for `openai`, total for `google`).

3.  **Generate the Report:**
    -   Present the aggregated data in a clear Markdown format. Use tables for clarity.
    -   **Note:** This workflow does not perform cost estimation. It only reports on token counts.

## Output Format

Your final output should be a Markdown report like this:

```markdown
# Token Usage Report

## Overall Summary

| Metric              | Value     |
| :------------------ | :-------- |
| Total Requests      | 3         |
| Total Input Tokens  | 5,500     |
| Total Output Tokens | 3,250     |
| **Grand Total**     | **8,750** |

## Usage by Provider

| Provider  | Total Tokens |
| :-------- | :----------- |
| openai    | 2,300        |
| anthropic | 3,700        |
| google    | 2,750        |

*This report is based on the data in `token_usage.log` and does not include real-time cost calculations.*
```
