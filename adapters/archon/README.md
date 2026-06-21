# Archon adapter

[Archon](https://github.com/coleam00/Archon) (by coleam00) can back team-rocket's two pluggable abstractions — the **task tracker** and the **persistent memory / knowledge** store — over MCP. This adapter explains how to wire it. Like the Beads adapter, none of it loads automatically; it's opt-in.

## Read this first: there are two Archons

Archon is mid-pivot, and the two versions fit team-rocket very differently:

| Version | What it is | Relationship to team-rocket |
|---|---|---|
| **current `main`** | A TypeScript **harness / workflow engine** — define dev processes (plan → implement → validate → review → PR) as YAML and run them. | **Overlaps team-rocket's orchestration layer.** It's an *alternative* process owner, not a backend. Don't wire it underneath team-rocket; you'd pick one to drive the workflow. team-rocket's distinct value is the behavioural layer (the James/Jessie/Meowth roles, the relentless plan interrogation, the quality bar, the named failure modes). |
| **`archive/v1-task-management-rag`** | The original **MCP server**: projects + tasks, a knowledge base (crawled sites, uploaded docs), and RAG search. | **This is the backend that fits.** Tasks ↔ team-rocket's tracker; knowledge base ↔ Meowth's memory; RAG ↔ grounding for discovery and the plan huddle. **This adapter targets v1.** |

**Caveat:** v1 lives on an *archived* branch — preserved and functional, but not the active development line. Adopt it knowing that. If you want the actively-developed Archon, that's the workflow engine on `main`, which is a different decision (replace team-rocket's orchestration, don't back it).

## What v1 gives team-rocket

| team-rocket abstraction | Archon v1 mechanism |
|---|---|
| **Task tracker** (story / goal / implementation) | Archon **projects + tasks** via the MCP server |
| **Persistent memory** (Meowth records & recalls) | Archon **knowledge base** — crawled docs, uploaded PDFs/specs/ADRs |
| **Discovery + plan-huddle grounding** | Archon **RAG search** over that knowledge base, so discovery and Phase-1 questioning pull from real sources instead of guessing |

The RAG/knowledge role is where Archon is strongest and where team-rocket is thinnest by default (Meowth's memory is otherwise "whatever the tracker offers"), so that's the highest-value part of this integration.

## Setup (Archon v1)

Follow the v1 branch's own README; in summary:

1. Check out `archive/v1-task-management-rag`.
2. Prerequisites: **Docker Desktop**, **Node.js 18+**, a **Supabase** project (Postgres + **pgvector**; local Supabase works), and an **LLM/embeddings key** (OpenAI, or Gemini/Ollama).
3. Copy `.env.example` → `.env`; set `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, and your embedding/LLM key. (Local Supabase: `SUPABASE_URL=http://host.docker.internal:8000`.)
4. Run `migration/complete_setup.sql` in the Supabase SQL editor.
5. Bring it up with Docker. Default ports: **UI 3737**, **Server API 8181**, **MCP 8051** (agents 8052/8053 optional).
6. MCP server is reachable at `http://${HOST}:${ARCHON_MCP_PORT}` (default `localhost:8051`), transport **SSE or stdio**.

## Wire it into team-rocket

1. **Connect the Archon MCP server** to your Claude Code session (add it as an MCP server pointing at the MCP port above).
2. **Discover the exact MCP tool names from your running instance.** The v1 docs describe capabilities — RAG queries, task CRUD, project operations — but don't pin tool names, and they vary by version. List your server's tools and record the real names (e.g. the RAG-query tool, the task create/list/update tools, the available-sources tool) so spawn prompts can call them precisely. **Don't guess tool names — read them off the instance.**
3. **Record the wiring in `TEAM-ROCKET.md`** (see snippet below) so the lead's spawn prompts reference Archon consistently.
4. **Seed the knowledge base.** Crawl the project's framework docs and upload its specs / ADRs into Archon, so the discovery prereq and Meowth can retrieve grounded context.

### `TEAM-ROCKET.md` snippet

```
## Task tracker
Tool: Archon v1 (MCP server at http://localhost:8051)
Access pattern: MCP tools — <task-create>, <task-list>, <task-update>, <project-*>
                (fill in the actual tool names from your instance)
Story hierarchy convention: Archon project = story; tasks = goals/implementations
Persistent memory: Archon knowledge base (RAG); recall via <rag-query-tool>

## Discovery & planning grounding
The discovery prereq and the plan huddle's Phase 1 query Archon RAG (<rag-query-tool>)
for framework docs / specs before drafting goals or answers.
```

## Mapping the story shape onto Archon

`/team-rocket:scheme` scaffolds story → discovery → goals → implementations. On Archon v1: create an Archon **project** for the story, then **tasks** for the discovery prereq, each goal, and each implementation, using the task-create MCP tool. Meowth records discoveries/decisions into the **knowledge base** rather than task comments where the content is reusable across stories (that's the RAG win).

## Caveats

- **v1 is archived; `main` is a different product.** Pin to the v1 branch deliberately.
- **Heavier infra than Beads** — Docker + Supabase/pgvector + an LLM key + several services, versus a single local binary. Worth it for the knowledge/RAG capability; overkill if you only need a task list.
- **Beta software.** Verify tool names and behaviour against your instance; don't trust hard-coded assumptions.
- **Headless/cron runs** may not have the Archon MCP server available (it's a local service) — the same caveat that applies to any interactively-connected MCP server.
- **Don't run team-rocket's cluster *inside* Archon's `main` workflow engine** without deciding which owns the process. They're two harnesses; pick one orchestrator.
