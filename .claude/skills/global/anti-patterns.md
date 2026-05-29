# Anti-Patterns Skill

## Never Do These

### Components
- ❌ God components — if it does more than one thing, split it
- ❌ Prop drilling more than 2 levels — lift state or use context
- ❌ Index as key in lists with dynamic order — use stable unique IDs
- ❌ useEffect for derived state — compute it inline
- ❌ Multiple useEffects that could be one — consolidate
- ❌ Mutating state directly — always return new references
- ❌ Anonymous arrow functions in JSX props on hot render paths

### Styling
- ❌ Raw hex/px values — use design tokens or config constants
- ❌ Inline styles for anything beyond truly dynamic values
- ❌ `!important` — fix specificity instead
- ❌ Pixel-perfect magic numbers with no explanation

### Data Fetching
- ❌ Fetching in useEffect without cleanup or abort controller
- ❌ Loading state without error state — handle both, always
- ❌ Ignoring race conditions on fast user interactions
- ❌ Storing server state in local state — use a cache layer

### TypeScript
- ❌ `any` — use `unknown` and narrow it
- ❌ Type assertions (`as SomeType`) without a comment explaining why
- ❌ Ignoring TS errors with `@ts-ignore` — fix them
- ❌ Duplicating types that already exist elsewhere in the codebase

### General
- ❌ Copy-pasting code more than twice — abstract it
- ❌ Commenting out code — delete it, git has history
- ❌ TODO comments older than one sprint — fix or delete
- ❌ Console.logs in committed code
- ❌ Hardcoded URLs, env values, or config in source
- ❌ Installing a library for something native APIs handle

## When Claude Catches One
State it plainly: `ANTI-PATTERN: [what] — [why it's a problem] — [preferred approach]`
