# UX/UI Core Principles & Rules

## 1. Core Philosophy

Our user experience should be **predictable, efficient, and accessible**. Every design decision must be justifiable based on these three principles.

## 2. Golden Rules

1.  **Clarity Over Cleverness:** The user should never have to guess what an icon or a label means. Use standard patterns and clear language.
2.  **Consistency is Key:** A button or a link should look and behave the same way everywhere in the application. Re-using components is mandatory.
3.  **Feedback is Mandatory:** Every user action must have immediate and clear feedback.
    -   *Example:* On form submission, disable the button and show a spinner.
    -   *Example:* On success, show a toast notification. On failure, show a clear error message.
4.  **Don't Make Me Think:** Design for scanning, not for reading. Use clear visual hierarchy (headings, bold text, lists) to guide the user's eye.
5.  **Accessibility is Not an Afterthought (WCAG 2.1 AA):**
    -   All images must have `alt` tags.
    -   All form inputs must have associated labels.
    -   Color contrast ratios must meet WCAG 2.1 AA standards.
    -   The application must be navigable using only a keyboard.

## 3. Common Interaction Patterns

-   **Forms:**
    -   Validation errors should appear inline, below the field, as the user types or on blur.
    -   The primary action button should be visually distinct (e.g., solid color) from the secondary action (e.g., outline).
-   **Data Tables:**
    -   Must support sorting on primary columns.
    -   Must use pagination for any dataset larger than 20 items.
-   **Modals & Dialogs:**
    -   Must be closable by clicking an "X" icon, pressing the Escape key, or clicking outside the modal.
    -   Must have a clear primary focus element when opened.
