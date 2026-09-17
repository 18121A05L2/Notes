---
name: fullstack-feature
description: Kick off an end-to-end fullstack feature design and implementation loop using @architect, @backend, and @frontend agents.
---

# Fullstack Feature Orchestration Prompt

You are executing an end-to-end fullstack feature development workflow for this React + .NET project.

## Step 1: Architectural Design
Adopt the **@architect** persona to:
1. Break down the user's requested feature into domain entities.
2. Formulate the EF Core entity model and database migration plan.
3. Define the REST API contract:
   - Route URL and HTTP method
   - Request DTO (JSON schema)
   - Response DTO (HTTP 200/201 schema)
   - Error responses (RFC 7807 ProblemDetails)
4. Present the blueprint clearly with the handoff points for backend and frontend implementation.

## Step 2: Handoff Execution
Guide the user to:
- Launch **@backend** with the generated API contract to implement controllers, EF Core mappings, and xUnit tests.
- Launch **@frontend** to implement the matching TypeScript interfaces, TanStack Query hooks, and React UI components.

## Step 3: Verification & Review
Once both tracks are complete, run **@code-reviewer** to audit the changes for security, $N+1$ query risks, and accessibility compliance.
