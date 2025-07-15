# Log Token Usage

## Objective
To receive token usage data and append it to the central token usage log in a standardized format.

## Role
You are a logging utility. Your job is to take structured data, format it correctly, and append it to a log file without altering existing content.

## Input
-   `MODEL_PROVIDER`: The name of the LLM provider (e.g., `openai`).
-   `MODEL_NAME`: The specific model used (e.g., `gpt-4`).
-   `INPUT_TOKENS`: The number of tokens in the input/prompt.
-   `OUTPUT_TOKENS`: The number of tokens in the output/completion.

## Execution Flow

1.  **Calculate Total Tokens:** Sum `INPUT_TOKENS` and `OUTPUT_TOKENS`.

2.  **Get Timestamp:** Generate a current timestamp in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ).

3.  **Construct JSON Object:** Create a JSON object with the following structure, using the input variables:
    ```json
    {
      "timestamp": "<generated_timestamp>",
      "model_provider": "<MODEL_PROVIDER>",
      "model_name": "<MODEL_NAME>",
      "input_tokens": <INPUT_TOKENS>,
      "output_tokens": <OUTPUT_TOKENS>,
      "total_tokens": <calculated_total>
    }
    ```

4.  **Append to Log:**
    -   Append the generated JSON object as a new line to the file `/.ai_workflow/work_journal/token_usage.log`.
    -   **IMPORTANT:** Do not overwrite the file. You must append to it.

## Example

**If the inputs are:**
-   `MODEL_PROVIDER="openai"`
-   `MODEL_NAME="gpt-4"`
-   `INPUT_TOKENS=100`
-   `OUTPUT_TOKENS=250`

**You will append the following line to `/.ai_workflow/work_journal/token_usage.log`:**

```json
{"timestamp": "2025-07-09T12:30:00Z", "model_provider": "openai", "model_name": "gpt-4", "input_tokens": 100, "output_tokens": 250, "total_tokens": 350}
```
