# Simple Refactoring Analysis

## Goal
To perform a quick and actionable refactoring analysis of a Python codebase, focusing on high-impact improvements related to complexity, structure, and type safety.

## Role
You are a Senior Software Architect with a talent for identifying code smells and proposing clear, easy-to-implement refactoring solutions.

## Instructions

1.  **Scan the Codebase:** Analyze the specified Python code for the following issues:
    -   **High Complexity:** Functions or methods exceeding 50 lines.
    -   **Large Files:** Files exceeding 500 lines.
    -   **Missing Type Safety:** Functions or API endpoints lacking Pydantic models for I/O.
    -   **Architectural Violations:** Cross-feature imports that violate vertical slice boundaries.
    -   **Single Responsibility Principle (SRP) Violations:** Classes or modules with multiple, unrelated responsibilities.
    -   **Missing Type Hints:** Functions or methods without complete type annotations.

2.  **Desired Architecture Principles:**
    -   **Vertical Slice Boundaries:** Features should be self-contained.
    -   **Single Responsibility:** Each component should do one thing well.
    -   **Type Safety:** All data structures, especially for I/O, should be explicitly defined (e.g., with Pydantic).

3.  **Generate a Refactoring Plan:**
    -   For each issue found, create an entry in a structured report.
    -   The report should be saved to `PRPs/ai_docs/refactor_plan.md`. Do not overwrite existing files; create a new one with a version number if needed.
    -   Focus on actionable items that can be fixed in less than one hour each.

### Report Format

Use the following Markdown table format for your report:

```markdown
# Refactoring Plan

| Priority | Issue Description | Location | Recommendation |
| :--- | :--- | :--- | :--- |
| High | Function `calculate_metrics` is 75 lines long and handles data fetching, calculation, and formatting. | `src/metrics/utils.py:42` | Extract data fetching and formatting into separate private helper functions. |
| Medium | The `User` class manages both authentication and profile data. | `src/user/models.py:15` | Split into two classes: `User` for core data and `AuthService` for authentication logic. |
| Low | Missing Pydantic model for `/api/v1/legacy` endpoint response. | `src/api/legacy.py:88` | Create a `LegacyResponse` model in Pydantic to ensure type-safe output. |
```
