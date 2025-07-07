# API Contract Definition

## Goal
To create a detailed, language-agnostic API contract that serves as a single source of truth for backend and frontend development, ensuring seamless integration.

## Role
You are a Senior API Designer. Your expertise lies in creating clear, consistent, and robust RESTful API contracts that are easy for both backend and frontend developers to implement.

## Instructions

For the feature described in `$ARGUMENTS`, generate a complete API contract specification. The contract should be comprehensive enough for parallel development.

### 1. Define RESTful Endpoints
-   List all necessary endpoints with their HTTP method, path, and a brief description.
-   Specify any query parameters for collection endpoints.

### 2. Define Data Transfer Objects (DTOs)
-   Provide clear Request and Response DTOs.
-   Use a generic, language-agnostic format (like TypeScript interfaces) to define the data structures.
-   Include comments for validation rules (e.g., `min`, `max`, `required`).

### 3. Define Error Responses
-   Specify a standardized JSON structure for error responses.

### 4. Define Validation Rules & Status Codes
-   List key validation rules and the corresponding HTTP status codes for success and failure scenarios.

### 5. Define Integration Requirements
-   Detail essential integration details like CORS, `Content-Type`, and authentication methods.

### 6. Add Implementation Notes
-   Provide high-level, language-specific hints for both backend (e.g., Java/Spring) and frontend (e.g., TypeScript/React) teams to guide their implementation.

### 7. Define Output
-   Save the final contract to `PRPs/contracts/{feature}-api-contract.md`.

---

## API Contract Template

### Feature: $ARGUMENTS

1.  **RESTful Endpoints**
    ```yaml
    Base URL: /api/v1/{feature}

    Endpoints:
      - GET /api/v1/{features}: Retrieve a paginated list of features.
      - GET /api/v1/{features}/{id}: Retrieve a single feature by its ID.
      - POST /api/v1/{features}: Create a new feature.
      - PUT /api/v1/{features}/{id}: Update an existing feature.
      - DELETE /api/v1/{features}/{id}: Delete a feature.
    ```

2.  **Data Transfer Objects (DTOs)**
    ```typescript
    // Request DTO (for POST/PUT)
    interface FeatureRequest {
      name: string;        // min: 2, max: 100
      description?: string; // max: 1000
      // Add other domain-specific fields here
    }

    // Response DTO (for GET)
    interface FeatureResponse {
      id: number;
      name: string;
      description?: string;
      createdAt: string;   // ISO 8601 format
      updatedAt: string;   // ISO 8601 format
    }
    ```

3.  **Standard Error Response**
    ```json
    {
      "timestamp": "2025-07-07T10:30:00Z",
      "status": 400,
      "error": "Bad Request",
      "message": "Validation failed for field 'name'.",
      "path": "/api/v1/{features}"
    }
    ```