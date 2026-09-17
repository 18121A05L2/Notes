# GitHub Copilot Fullstack Agent Orchestration: React + .NET

This guide details how to build and orchestrate multi-agent workflows specifically using **GitHub Copilot in VS Code** for a fullstack **React + ASP.NET Core** project.

---

## 1. GitHub Copilot Architecture Overview

```
                         USER PROMPT (in Copilot Chat)
                               │
                .github/copilot-instructions.md
                (Always-on project rules & tech stack)
                               │
                       @architect (PARENT)
                    (Analyzes & Designs Contract)
                               │
                    ┌──────────┴──────────┐
                    │  PARALLEL HANDOFFS  │
                    ▼                     ▼
          @backend (.NET)          @frontend (React)
      ┌──────────────────────┐   ┌──────────────────────┐
      │ • EF Core Entities   │   │ • TypeScript Types   │
      │ • Web API Endpoints  │   │ • TanStack Query     │
      │ • FluentValidation   │   │ • UI Components/Form │
      │ • xUnit Tests        │   │ • Vitest/Playwright  │
      └──────────┬───────────┘   └──────────┬───────────┘
                 │                          │
                 └────────────┬─────────────┘
                              ▼
                      @code-reviewer
                 (Security & Quality Audit)
                              │
                              ▼
                     DEPLOYMENT READY
```

---

## 2. GitHub Copilot Files & Folder Setup

```text
my-app/
├── .github/
│   ├── copilot-instructions.md      # 1. Copilot Persistent Instructions (Always-on)
│   │
│   ├── prompts/                     # 2. Reusable Prompt Files (Triggered via `/`)
│   │   └── fullstack-feature.prompt.md
│   │
│   └── agents/                      # 3. Custom Copilot Agents (.agent.md)
│       ├── architect.agent.md       #    - Parent Orchestrator (@architect)
│       ├── backend.agent.md         #    - .NET / C# Specialist (@backend)
│       ├── frontend.agent.md        #    - React / TS Specialist (@frontend)
│       ├── code-reviewer.agent.md   #    - Security & Quality Auditor (@code-reviewer)
│       └── workflows/
│           └── react-dotnet-orchestration.md
│
├── .vscode/
│   └── mcp.json                     # 4. Model Context Protocol (MCP) Tool Servers
│
├── backend/                         # ASP.NET Core Solution
│   ├── src/
│   │   ├── Domain/
│   │   ├── Application/
│   │   ├── Infrastructure/
│   │   └── Api/
│   └── tests/
│
└── frontend/                        # React Application (Vite / Next.js)
    ├── src/
    │   ├── api/
    │   ├── components/
    │   └── types/
    └── package.json
```

---

## 3. The 4 Key GitHub Copilot Components

### Component 1: Custom Instructions (`.github/copilot-instructions.md`)
- **Scope**: Repository-wide, persistent.
- **Behavior**: GitHub Copilot loads this file automatically with **every single request** in Copilot Chat and Copilot Edits.
- **Purpose**: Establishes global constraints (e.g., C# 12, ASP.NET Core, React 19, strict TypeScript, RFC 7807 error formats) and tells Copilot about the available `@` custom agents.

---

### Component 2: Custom Agents (`.github/agents/*.agent.md`)
Custom agents are defined with YAML frontmatter + Markdown system instructions:

```yaml
---
name: architect
description: System Architect for React + .NET applications.
tools: ["read", "search"]
model: "claude-3-5-sonnet"
target: "vscode"
handoffs:
  - label: "Delegate to Backend (.NET)"
    agent: "backend"
    prompt: "I have designed the system architecture. Please implement the ASP.NET Core backend endpoints."
    send: true
  - label: "Delegate to Frontend (React)"
    agent: "frontend"
    prompt: "Here is the API contract and DTO schema. Please implement the React components."
    send: true
---
```

#### Copilot Frontmatter Fields:
- **`name`**: The identifier used in chat (e.g., `@architect`).
- **`description`**: Required. Describes when Copilot should route to this agent.
- **`tools`**: Restricts tool capabilities (e.g., `["read", "search", "edit", "shell"]`).
- **`model`**: Model choice (e.g., `claude-3-5-sonnet`, `gpt-4o`).
- **`handoffs`**: Interactive transition buttons rendered in Copilot Chat.

---

### Component 3: Prompt Files (`.github/prompts/*.prompt.md`)
- **Scope**: Task-specific, triggered on-demand.
- **Invocation**: Type `/` in Copilot Chat (e.g., `/fullstack-feature`).
- **Purpose**: Encodes reusable, standardized multi-step prompts without re-typing prompt instructions.

---

### Component 4: Model Context Protocol (`.vscode/mcp.json`)
Allows GitHub Copilot agents to directly interact with databases and browsers:
- **`database` (`server-postgres`)**: Lets `@backend` verify EF Core tables and run schema introspection.
- **`playwright` (`playwright-mcp-server`)**: Lets `@frontend` verify UI components in a headless Chromium browser.
- **`fetch` (`server-fetch`)**: Lets agents inspect live Swagger / OpenAPI JSON endpoints (`http://localhost:5000/swagger/v1/swagger.json`).

---

## 4. End-to-End Walkthrough in GitHub Copilot Chat

### Step 1: Triggering the Workflow
In VS Code Copilot Chat, the developer types:
```text
/fullstack-feature Add an Order History feature where users can place orders and view past transactions.
```
*Copilot activates the `/fullstack-feature` prompt file and delegates to `@architect`.*

---

### Step 2: The Architect Phase (@architect)
`@architect` evaluates the feature and generates:
1. **EF Core Entity**: `Order` and `OrderItem` models.
2. **REST API Contract**:
   - `POST /api/v1/orders`
   - `GET /api/v1/orders`
3. **DTO Schemas & Validation Rules**:
   - `CreateOrderDto`, `OrderResponseDto`
4. **Handoff Buttons**: Copilot displays two interactive buttons at the bottom of the response:
   - `[Delegate to Backend (.NET)]`
   - `[Delegate to Frontend (React)]`

---

### Step 3: Parallel Execution via Handoffs

#### Track A: Backend Development (@backend)
1. Developer clicks **`[Delegate to Backend (.NET)]`**.
2. Copilot switches context to `@backend` with `tools: ["read", "search", "edit", "shell"]`.
3. `@backend`:
   - Adds the C# entity configurations in `Infrastructure/Data/Configurations/`.
   - Generates and applies the EF Core migration via terminal (`dotnet ef migrations add`).
   - Implements `OrdersController` with FluentValidation.
   - Runs `dotnet test` to verify xUnit test cases.
4. When finished, `@backend` offers handoff: `[Handoff to Frontend (React)]` and `[Request Code Review]`.

#### Track B: Frontend Development (@frontend)
1. Developer clicks **`[Delegate to Frontend (React)]`**.
2. Copilot switches context to `@frontend`.
3. `@frontend`:
   - Generates TypeScript interfaces in `src/types/order.ts`.
   - Creates `useOrders` and `useCreateOrder` custom hooks using **TanStack Query**.
   - Builds the `<OrderHistoryTable />` and `<CreateOrderForm />` with Zod validation.
   - Verifies the rendered DOM via the `playwright` MCP tool.
4. When finished, `@frontend` offers handoff: `[Request Code Review]`.

---

### Step 4: Fullstack Security & Quality Audit (@code-reviewer)
1. Developer clicks **`[Request Code Review]`**.
2. Copilot switches context to `@code-reviewer`.
3. `@code-reviewer`:
   - Checks the combined changes across both `.cs` and `.tsx` files.
   - Scans for SQL injection, EF Core $N+1$ query overhead, missing `CancellationToken` propagation, and CSRF/CORS issues.
   - Outputs a concise markdown report with severity ratings (Critical, High, Medium, Low) and proposed code diffs.
