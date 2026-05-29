# Code Quality Skill

## Core Principles
- One concern per function, component, or module
- Name things for what they do, not what they are
- If you need a comment to explain what it does, rename it first
- Delete code over commenting it out

## Naming
- Functions: verb phrases — `fetchUser`, `formatDate`, `isValidEmail`
- Booleans: `is`, `has`, `can`, `should` prefix — `isLoading`, `hasError`
- Components: PascalCase nouns — `UserCard`, `CommitSummary`
- Constants: SCREAMING_SNAKE for true constants — `MAX_RETRIES`
- Never: `data`, `info`, `temp`, `stuff`, `handleThing`

## Complexity Thresholds
- Max function length: 30 lines — if longer, split it
- Max component length: 150 lines — if longer, extract
- Max nesting depth: 3 levels — flatten with early returns
- Max params: 3 — beyond that, pass an object

## Functions
- Pure functions preferred — same input always gives same output
- Side effects isolated and explicit
- Early returns over nested conditionals
- No boolean parameter flags — split into two functions

## Components
- Single responsibility — one reason to change
- Props destructured at the top
- No business logic in components — extract to hooks or utils
- No inline styles unless truly one-off and trivial

## State Management
- Keep state as local as possible
- Derived state never stored — compute it
- No redundant state that mirrors props

## Imports
- Absolute imports over deep relative paths
- Group: external libs → internal modules → local files → types
- No wildcard imports (`import * as`)

## What "Done" Means
- Works as intended
- Handles error and empty states
- Accessible
- Has tests for behavior
- No console.logs left in
- No commented-out code
