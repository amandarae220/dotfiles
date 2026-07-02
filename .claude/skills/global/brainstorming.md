# Brainstorming

Use before any creative work — creating features, building components, adding functionality, or modifying behavior. Explores intent, requirements, and design before implementation.

**HARD GATE:** Do NOT write any code, scaffold any project, or take any implementation action until you have presented a design and Amanda has approved it. This applies to every task regardless of perceived simplicity.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Process Checklist

Complete in order:

1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time; understand purpose, constraints, success criteria
3. **Propose 2–3 approaches** — with trade-offs and a recommendation
4. **Present design** — in sections scaled to complexity; get approval after each section
5. **Write design doc** — save to `docs/specs/YYYY-MM-DD-<topic>-design.md` and commit
6. **Spec self-review** — check for placeholders, contradictions, ambiguity, scope
7. **Amanda reviews written spec** — ask her to review before proceeding
8. **Transition to implementation** — invoke `writing-plans` skill

## Process Flow

```
Explore context
  → Ask clarifying questions (one at a time)
    → Propose 2-3 approaches
      → Present design sections (get approval after each)
        → Write design doc
          → Spec self-review (fix inline)
            → Amanda reviews spec
              → Invoke writing-plans
```

The terminal state is invoking `writing-plans`. Do NOT start coding directly after brainstorming.

## The Process

**Understanding the idea:**

- Check current project state first (files, docs, recent commits)
- Assess scope before asking detailed questions. If the request describes multiple independent subsystems, flag this first — help decompose into sub-projects before proceeding.
- Ask questions one at a time. Multiple-choice preferred when possible.
- Focus on: purpose, constraints, success criteria.

**Exploring approaches:**

- Propose 2–3 different approaches with trade-offs
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you understand what's being built, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200–300 words if nuanced
- Ask after each section: "Does this look right so far?"
- Cover: architecture, components, data flow, error handling, testing

**Design principles:**

- Break the system into units with one clear purpose, well-defined interfaces, and independent testability
- For each unit: what does it do, how do you use it, what does it depend on?
- Smaller, well-bounded units are easier to reason about and test
- In existing codebases, follow existing patterns. Only propose targeted improvements that serve the current goal — no unrelated refactoring.

## After the Design

**Documentation:**

- Write the validated design to `docs/specs/YYYY-MM-DD-<topic>-design.md`
- Commit the design doc to git

**Spec Self-Review:**

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other?
3. **Scope check:** Is this focused enough for a single implementation plan?
4. **Ambiguity check:** Could any requirement be interpreted two ways? Pick one.

Fix issues inline. Then ask Amanda to review before proceeding.

**Review Gate:**

> "Spec written and committed to `<path>`. Please review it and let me know if you want any changes before we start the implementation plan."

Wait for approval. Only then invoke `writing-plans`.

## Key Principles

- **One question at a time** — don't overwhelm
- **YAGNI ruthlessly** — remove unnecessary features from all designs
- **Explore alternatives** — always propose 2–3 approaches
- **Incremental validation** — present design, get approval, then move on
- **Be flexible** — go back and clarify when something doesn't make sense
