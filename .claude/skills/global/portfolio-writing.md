# Portfolio Writing — AL's Voice & Editorial Standards

Applies to: any **portfolio piece** (data-journalism essay, interactive
explainer, civic-tech tool, personal-brand landing page). Not for
throwaway internal docs or code comments.

Read this before touching prose, section structure, or interactive-tool
copy in a portfolio project. Enforce every rule below unless AL has
explicitly overridden it for this piece.

---

## 1. Voice

- **Direct, concrete, teacher-explaining.** Not academic. Not polemic.
  Not think-tank. Never preachy.
- **Republican direct-messaging clarity.** The reader should feel like
  they understand and relate — not like they're being lectured. Clarity
  is the persuasion.
- **Numbers do the persuading, not adjectives.** If a sentence would
  survive with the adjective removed, remove it.
- **No apologies, no preamble, no meta-commentary.** Show the thing.
  Explain if — and only if — explanation adds value.

**Voice test:** read the sentence aloud. If it sounds like a smart
teacher explaining something real to someone smart who isn't a policy
wonk, keep it. If it sounds like a white paper or a manifesto, rewrite.

---

## 2. One thesis. Cut the other.

AL's instinct is to write both the data-journalism piece and the
reflective essay inside the same project. Editorially, this fails —
the data reader hits the essay parts and thinks *this got soft*; the
essay reader hits the numbers and thinks *this got clinical*.

**Rule:** Every portfolio piece commits to exactly one of these:

- **ROI / analytical thesis** — numbers carry the argument, reader
  leaves with a tool or an actionable frame.
- **Sociological / reflective thesis** — prose carries the argument,
  reader leaves with a moral case or a lens.

If both are on the page, kill one. If the analytical case is strong
and the sociological case is competent-but-not-distinctive, kill the
sociological case. AL is stronger on the data side; most competing
essay content has already been written by someone else.

**Test:** describe the piece in one sentence. If you need "and also"
or "which touches on," you have two theses.

---

## 3. Own your rhetorical framings

Any time a comparison is illustrative rather than causal — for example,
"California's surplus is 216× Georgia's margin" — the copy must
acknowledge the framing explicitly. A trained reviewer catches
unowned rhetoric within seconds and stops trusting the piece.

**Bad:** "California's surplus could have flipped Georgia 216 times over."

**Good:** "California's surplus was 216 times Georgia's decisive margin.
Those votes couldn't cross state lines — that's precisely what makes
geography so decisive."

The extra sentence costs almost nothing and buys the entire piece's
credibility.

---

## 4. Model your own remedy

If the piece argues for an action, **show what happens when the action
happens.** Don't leave the reader to trust the causal claim.

For a piece arguing "voters should move to swing states": model the
effect of N thousand movers on the surplus map. For a piece arguing
"buy an EV": model household savings and grid load. For a piece
arguing "adopt policy X": model the counterfactual.

This is the single change that separates "argued well" (B+) from
"proved by the data" (A-tier) in portfolio work.

---

## 5. Deliver the payoff at peak engagement

The actionable tool — calculator, interactive, quiz — goes on the
**main page**, at the point the reader is most invested. Never behind
a click.

Multi-page architecture is almost always wrong for portfolio work.
Reason: the reader has to invest the biggest cognitive act (a nav
click) at the moment they've already been convinced. Collapse to
one page whenever the arc fits.

Corollary: **hero stats must be the loudest thing on screen at their
scroll position**, bigger than any headline nearby. If a hero number
is under `clamp(5rem, 18vw, 10rem)` it isn't the hero.

---

## 6. Cite the academic ground once

One sentence in the closer citing a peer-reviewed source relevant to
the piece's frame buys real credibility with any reviewer who's
serious about the domain. Examples used elsewhere:

- Political geography: Rodden, *Why Cities Lose*
- Rural resentment: Cramer, *The Politics of Resentment*
- Ideological sorting: Bishop, *The Big Sort*

Cost: ~10 words. Return: signals AL knows the intellectual lineage of
the frame, not just the current data. Do this exactly once, in the
closer, unless there's a specific reason to cite more.

---

## 7. Sourcing hygiene

- **Every stat is sourced inline** with an institution the reviewer
  recognizes (MIT Election Lab, Census ACS, BLS, Zillow Research,
  BEA, OpenElections, Ballotpedia — plus academic sources under §6).
- **Source list at the footer** in mono, muted, ~13px. Not decorated.
- **No unsourced round numbers.** "About 50 million" without a
  citation is worse than the precise figure with one.
- **Acknowledge feasibility scale honestly.** If the piece argues a
  remedy that takes thousands of movers, say "thousands of movers, not
  hundreds." Reviewers respect honesty about scale more than they
  respect optimism.

---

## 8. Even-handedness for political work

- Show both parties' surplus, both parties' margins, both parties'
  offensive plays. Symmetry is a credibility move.
- Direction toggles (D/R, blue/red) must be **truly symmetric** in
  the underlying math. Same formula, same normalization, same
  guarantees.
- Never frame one party's advantage as illegitimate. "Sorting"
  applies to both. "Gerrymandering" applies to both.
- AL is a government contractor. Political projects must stay
  non-partisan and data-forward. No sensationalism.

---

## 9. Banned vocabulary

**Never use:**

wasted · fraud · rigged · stolen · suppressed · shut out · piled up ·
already decided · already set · structural problem · geographic
concentration · intellectual flight · classism · brain drain ·
inflection point · organically (in political context) · legally
defensible · accountable (as policy-speak) · organic undoing

**Reason these are banned:** they either (a) editorialize where the
data should do the work, or (b) telegraph the piece as partisan or
academic when the voice is meant to be direct.

**When tempted to smuggle a banned concept in as different wording:**
either commit to the argument openly (cite the sociological source
and defend it) or cut it. Half-smuggling is worse than either.

---

## 10. Structural rules

- **Single-page unless there's a specific reason for two.** If two
  pages exist, no framing repeats between them.
- **Interactive tools build on each other**, not context-switch.
  Overview map → drill-in → destination calculator is a coherent
  chain. Three unrelated tools is not.
- **Consistent vocabulary across tools.** If one tool labels races
  "Razor thin / Competitive / Shifting," every other tool in the
  piece uses the same three words with the same color palette.
- **Design tokens only.** Every color, every font-size, every
  spacing value comes from `app.css` tokens. No component-level raw
  values.
- **Every UI component meets WCAG 2.1 AA.** Focus-visible outlines,
  color contrast, keyboard reachable, `aria-pressed` on toggles,
  `prefers-reduced-motion` respected on animations.

---

## 11. Technical case-study README

Every portfolio piece ships with a `README.md` that names, explicitly:

- **What's custom-built** vs. plugged-in library
- **The novel metric or approach** the piece introduces (e.g.,
  "surplus votes" as a per-county leverage measure)
- **The technical challenges** solved (e.g., single-SVG scroll-driven
  D3 with no remount, per-state projection fit, precinct-to-district
  crosswalks)
- **All data sources** in a table with what each is used for
- **Run-locally instructions** (`npm install`, `npm run dev`,
  `npm run build`)

Reviewers skim; they won't infer effort from a screenshot. If the
work isn't in the README, it doesn't exist.

---

## 12. Housekeeping

Before shipping any portfolio piece:

- [ ] No dead links, no 404s, no unresolved `href="/foo"` promises
- [ ] Mobile audit — dot maps reflow, scroll-triggered animations
      don't stutter, overlay panels don't overflow viewport
- [ ] `prefers-reduced-motion` honored on every transition
- [ ] All hero stats are the loudest element at their scroll position
- [ ] Duplicate framings across sections eliminated
- [ ] Component files that are no longer imported are either deleted
      or explicitly noted as "preserved for future salvage"
- [ ] Vercel/deploy config verified (clean URLs on, trailing-slash
      resolved, `outputDirectory` set)
- [ ] README/case-study up to date with what's actually built

---

## Reference: where this skill came from

Extracted from the editorial process of shipping *Where It Counts*
(surplus-vote scrollytelling + relocation-impact calculator, 2026).
Where a rule below cites a specific number or framing, it's an
example from that project — not a mandatory pattern.
