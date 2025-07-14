# Technical Specifications

## 1. Frontend Framework

- **Framework:** React (via Next.js)
- **Language:** TypeScript
- **Styling:** CSS Modules / Tailwind CSS (TBD)

## 2. State Management

- **Primary Solution:** React Context API for simple state.
- **Complex State:** Zustand or Redux Toolkit (TBD based on application complexity).

## 3. API Communication

- **Protocol:** RESTful APIs over HTTPS.
- **Data Format:** JSON.
- **Client:** `fetch` API or a lightweight wrapper like `SWR`.

## 4. Code Conventions

- **Formatting:** Prettier with the configuration in `.prettierrc`.
- **Linting:** ESLint with the configuration in `.eslintrc.json`.
- **Naming:**
    - Components: `PascalCase` (e.g., `UserProfile.tsx`)
    - Functions/Variables: `camelCase` (e.g., `getUserProfile`)
    - CSS Classes: `kebab-case` (e.g., `user-profile-card`)

## 5. Testing

- **Unit Tests:** Jest + React Testing Library.
- **Integration Tests:** Playwright or Cypress (TBD).
- **Test File Location:** Tests must be co-located with the components they are testing (e.g., `UserProfile.test.tsx`).
