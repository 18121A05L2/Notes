# GitHub Copilot Repository Instructions

This file provides persistent context and guidelines for **GitHub Copilot** across this repository.

---

## 1. Tech Stack Overview

- **Backend**: .NET 8 / .NET 9, C# 12+, ASP.NET Core Web API, Entity Framework Core.
- **Frontend**: React 18/19, TypeScript (strict mode), Vite, TanStack Query (v5), Tailwind CSS.
- **Database**: PostgreSQL / SQL Server with EF Core Migrations.
- **Testing**: xUnit, FluentAssertions, Moq (Backend); Vitest, Playwright (Frontend).

---

## 2. Coding Standards & Architectural Patterns

### Backend (.NET)

- **API Style**: RESTful, returning RFC 7807 `ProblemDetails` for errors.
- **Data Access**: Configure EF Core entities with Fluent API (`IEntityTypeConfiguration<T>`). Never use tracking queries (`.AsNoTracking()`) for read-only operations. Always use projections (`.Select()`) to prevent $N+1$ query issues.
- **Validation**: Enforce business validation via FluentValidation before domain execution.
- **Async Handling**: All asynchronous methods must accept and forward a `CancellationToken`.

### Frontend (React)

- **State Management**: Use TanStack Query for server state caching, invalidation, and mutations. Avoid unnecessary global stores.
- **Types**: All TypeScript interfaces must strictly reflect backend DTOs.
- **Forms**: Use React Hook Form with Zod schema validation matching backend validation rules.
- **Components**: Adhere to semantic HTML5, keyboard navigation, and ARIA standards.

---

## 3. GitHub Copilot Custom Agents (.github/agents/)

When tackling complex, multi-file features, Copilot should delegate to or adopt the specialized custom agents defined in `.github/agents/`:

| Agent                 | Invocation           | Role                                                                                        | Primary File                                |
| :-------------------- | :------------------- | :------------------------------------------------------------------------------------------ | :------------------------------------------ |
| **Architect**         | `@architect`         | Requirements analysis, EF Core schema, REST API contract, and handoff plan                  | `.github/agents/architect.agent.md`         |
| **Backend**           | `@backend`           | ASP.NET Core controllers, services, EF Core migrations, and xUnit tests                     | `.github/agents/backend.agent.md`           |
| **Frontend**          | `@frontend`          | React UI, TypeScript types, TanStack Query hooks, and form components                       | `.github/agents/frontend.agent.md`          |
| **Frontend Reviewer** | `@frontend-reviewer` | Frontend correctness, accessibility, security, performance, visual quality, and test review | `.github/agents/frontend-reviewer.agent.md` |
| **Code Reviewer**     | `@code-reviewer`     | Fullstack security scan, performance profiling, and PR audit                                | `.github/agents/code-reviewer.agent.md`     |

---

## 4. Reusable Prompt Files (.github/prompts/)

- Use `/fullstack-feature` to initiate the end-to-end orchestration pipeline from architecture design to implementation.
- Use `/test` to create safe, step-by-step MacBook and macOS setup or troubleshooting instructions.
