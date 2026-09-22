# Building the "Boss Brain Reply Master" Agent in Microsoft Copilot Studio & VS Code

> Based on the deep-dive tutorial **"Build NEXT-LEVEL Copilot Agents with VS Code & GitHub Copilot"** (YouTube ID: `TrZ6fKBENB8`) by Shervin Shaffie (*Collaboration Simplified*).

---

## 1. What is "Boss Brain Reply Master"?

In the tutorial, Microsoft Principal Copilot Engineer Shervin Shaffie shows how to transition from a basic question-and-answer chatbot into an **autonomous, proactive agentic workflow**.

The agent, named **Boss Brain Reply Master**, is designed to act as an executive-level co-pilot and gatekeeper:
1. **Persona & Standards**: Grounded in the thinking style and communication preferences of an executive leader (in Shervin's demo, modeled after **Albert Einstein** — prioritizing simplicity, intellectual rigor, brevity, and zero corporate jargon).
2. **Autonomous Triggering**: Automatically wakes up when an email arrives in Outlook with a proposal, draft, or document review request.
3. **Multi-Tool Orchestration (Model Context Protocol - MCP)**:
   - **Work IQ Context**: Queries Microsoft 365 workplace context (previous chats, meetings, emails).
   - **Work IQ Word MCP (`WorkIQWordMCP`)**: Opens the attached Word document, critiques each section against the boss's rubric, rewrites dense or jargon-filled sections, and saves the revised draft to OneDrive.
   - **Work IQ Mail MCP (`WorkIQMailMCP`)**: Composes a concise, executive-level reply summarizing the changes and attaches the revised document.
   - **Work IQ Teams MCP (`WorkIQTeamsMCP`)**: Sends an Adaptive Card notification to Microsoft Teams to keep the human in the loop.

---

## 2. Architecture & File Structure

The project has been generated in your workspace at `Notes/AI/BossBrainReplyMaster/`:

```
BossBrainReplyMaster/
├── agent.mcs.yml                           # Main agent identity & system instructions
├── settings.mcs.yml                        # Model (GPT-4o), generative orchestration & dynamic chaining
├── connectionreferences.mcs.yml            # M365 connection references (Work IQ, Outlook, Word, Teams, OneDrive)
├── icon.png                                # Agent avatar icon
├── README.md                               # Quick-start documentation
├── actions/                                # MCP Tool definitions & custom actions
│   ├── WorkIQMailMCP-WorkIQMailPreview.mcs.yml      # Mail MCP actions (search, get details, draft, send)
│   ├── WorkIQWordMCP-WorkIQWordPreview.mcs.yml      # Word MCP actions (read, revise, comment, save)
│   ├── WorkIQTeamsMCP-WorkIQTeamsPreview.mcs.yml    # Teams MCP actions (post adaptive card, notify chat)
│   ├── ca_agentE-0Ks.topic.WorkIQCopilot.mcs.yml   # Copilot graph context reasoning
│   └── ca_agentE-0Ks.topic.WorkIQUserPreference.mcs.yml # Boss preference & tone lookup
├── knowledge/                              # Grounding sources
│   ├── Einstein_Executive_Guidelines.md   # Grounding rules (rubrics, tone, email length, style)
│   └── knowledge.mcs.yml                   # Knowledge connector mapping
├── trigger/                                # Autonomous triggers
│   └── OnEmailReceivedTrigger.mcs.yml      # Triggers on incoming Outlook emails with attachments
├── workflows/                              # Orchestrated agentic pipelines
│   └── AutonomousEmailDocumentWorkflow.mcs.yml # End-to-end autonomous review loop
└── topics/                                 # Chat topics
    ├── AutonomousReviewTopic.mcs.yml       # Interactive chat review topic
    └── ConversationalFallback.mcs.yml      # Generative fallback topic
```

---

## 3. How to Create This in Microsoft Copilot Studio (Web Portal UI)

If you are building this directly in the Copilot Studio web portal ([copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)):

### Step 1: Create the Agent
1. Go to **Microsoft Copilot Studio** and click **Create** > **New agent**.
2. Set the Name to `Boss Brain Reply Master`.
3. Set the Description:
   ```text
   Helps users align communications, documents, and deliverables with executive leadership preferences and tone, autonomously reviewing requests, editing documents, and drafting replies.
   ```

### Step 2: Configure System Instructions
In the **Overview** > **Instructions** text box, paste the structured prompt:
```markdown
# Purpose
Guide users to align communications, documents, and deliverables with executive leadership standards. Autonomously review incoming emails, critique and revise attached documents using Work IQ and Word MCP tools, draft professional replies in Outlook, and post activity summaries to Microsoft Teams.

# General Guidelines
- Maintain a thoughtful, analytical, rigorous, and professional tone.
- Reference known executive values: simplicity, extreme clarity, intellectual rigor, brevity (modeled after Albert Einstein's philosophy: "Everything should be made as simple as possible, but not simpler").
- Eliminate corporate buzzwords, passive voice, and convoluted jargon.
- Clearly explain the rationale behind any suggested changes.

# Skills
- Identify and summarize leadership communication preferences.
- Analyze incoming email queries and attached Word documents against these standards.
- Autonomously execute document revisions using WorkIQWordMCP.
- Generate executive email replies with attached revised files using WorkIQMailMCP.
- Notify the team via Adaptive Cards in Teams using WorkIQTeamsMCP.
```

### Step 3: Add Knowledge
1. Go to the **Knowledge** tab.
2. Click **Add knowledge**.
3. Upload files containing executive guidance (e.g., `Einstein_Executive_Guidelines.md` or your leader's email transcripts and style guides).
4. Enable **Enterprise Data / M365 Graph Grounding** so the agent can reference shared SharePoint sites and organization emails.

### Step 4: Add Actions (MCP Tools & Connectors)
1. Go to the **Actions** tab.
2. Click **Add an action**.
3. Select **Model Context Protocol (MCP)** or **Connectors**:
   - **Work IQ Mail**: Select actions `Get email details`, `Create reply draft`, and `Send email`.
   - **Work IQ Word / Word Online**: Select actions `Read document content`, `Revise document sections`, and `Save as revised draft`.
   - **Work IQ Teams / Microsoft Teams**: Select actions `Post adaptive card to channel` and `Send chat notification`.
   - **OneDrive for Business**: Select `Create file` and `Get file content`.

### Step 5: Configure Generative Orchestration
1. Go to **Settings** > **Generative AI**.
2. Set orchestration to **Generative (dynamic chaining)**:
   - This allows the agent to dynamically plan which tool to call next (e.g. read email -> download file -> call Word MCP -> draft reply -> notify Teams) without hardcoding rigid rule trees.
3. Select **GPT-4o** as the model.
4. Set Moderation Level to **Medium**.

### Step 6: Configure Autonomous Event Trigger
1. In Copilot Studio (with Autonomous Agent features enabled), navigate to **Triggers**.
2. Add a new trigger: **When a new email arrives (V3)** (Office 365 Outlook).
3. Set filters:
   - Subject filter: `Review|Proposal|Draft|Feedback`
   - Only with attachments: `True`
4. Connect this trigger to your autonomous review action/workflow.

### Step 7: Test & Publish
1. Use the **Test your agent** side panel to test interactive triggers ("Review this proposal for me").
2. Send a test email to your connected mailbox with a sample `.docx` proposal attached.
3. Watch the agent trigger autonomously, revise the Word doc, prepare the draft, and send a Teams card.
4. Click **Publish** to make it available across Microsoft 365 Copilot, Outlook, and Microsoft Teams.

---

## 4. How to Use the Pro-Code Workflow (VS Code & GitHub Copilot)

This is the exact workflow Shervin Shaffie highlights in the video:

### Step 1: Install the VS Code Extension
- Install the **Microsoft Copilot Studio** extension from the VS Code Marketplace.
- Install the **GitHub Copilot** extension.

### Step 2: Clone Your Agent
1. Open the Copilot Studio tab on the VS Code Activity Bar (left sidebar).
2. Sign in to your Microsoft 365 / Power Platform environment.
3. Click **Clone agent** and select `Boss Brain Reply Master`.
4. Choose your local directory (`Notes/AI/BossBrainReplyMaster/`).

### Step 3: Edit `.mcs.yml` Files with GitHub Copilot
- VS Code gives you full Git version control, branch management, and multi-file editing.
- Use **GitHub Copilot Chat**:
  - Type `/init` to let Copilot scan and understand the `.mcs.yml` schema.
  - Type `/plan` to outline agentic logic (e.g., "Add autonomous email trigger and Word MCP document editor").
  - Switch Copilot to **Agent Mode** to automatically generate and validate action YAMLs.

### Step 4: Push Changes Back to Copilot Studio
- When you finish editing YAML locally, open the Copilot Studio extension in VS Code.
- Click **Push / Sync** to upload the local changes back to the cloud.
- Your updates are immediately reflected in the Copilot Studio web portal.
