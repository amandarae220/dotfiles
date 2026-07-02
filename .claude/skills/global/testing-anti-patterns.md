# Testing Anti-Patterns

**Load this when:** writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

**Core principle:** Test what the code does, not what the mocks do.

## The Iron Laws

```
1. NEVER test mock behavior
2. NEVER add test-only methods to production classes
3. NEVER mock without understanding dependencies
```

## Anti-Pattern 1: Testing Mock Behavior

```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});

// ✅ GOOD: Test real component behavior
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});
```

**Gate:**
> Am I testing real behavior or just mock existence? If mock existence → delete assertion, unmock the component.

## Anti-Pattern 2: Test-Only Methods in Production Classes

```typescript
// ❌ BAD: destroy() only called in tests
class Session {
  async destroy() { /* cleanup */ }
}
afterEach(() => session.destroy());

// ✅ GOOD: Test utilities handle cleanup
// test-utils/session.ts
export async function cleanupSession(session: Session) { /* cleanup */ }
afterEach(() => cleanupSession(session));
```

**Gate:**
> Is this method only called by tests? → Move it to test utilities.

## Anti-Pattern 3: Mocking Without Understanding

```typescript
// ❌ BAD: Mock prevents side effect the test depends on
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));
// Test silently passes for wrong reason

// ✅ GOOD: Mock at the correct level
vi.mock('MCPServerManager'); // Mock slow startup only, preserve config writes
```

**Gate:**
> What side effects does the real method have? Does this test depend on any of them?
> Run with real implementation FIRST. Observe what's needed. THEN mock minimally.

**Red flags:** "I'll mock this to be safe" / "This might be slow" / mocking without tracing the dependency chain.

## Anti-Pattern 4: Incomplete Mocks

```typescript
// ❌ BAD: Only mocking fields you think you need
const mockResponse = { status: 'success', data: { userId: '123' } };
// Breaks when downstream code accesses response.metadata.requestId

// ✅ GOOD: Mirror the real API completely
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
};
```

**Rule:** Mock the complete data structure. Partial mocks fail silently.

## Anti-Pattern 5: Tests as Afterthought

```
❌ Implement → test later (or never)
✅ Write failing test → implement → refactor (TDD)
```

## When Mocks Get Too Complex

Warning signs:
- Mock setup longer than test logic
- Mocking everything just to make something pass
- Test breaks when mock changes

Consider: integration tests with real components are often simpler than complex mocks.

## Quick Reference

| Anti-Pattern | Fix |
|--------------|-----|
| Assert on mock elements | Test real behavior or unmock |
| Test-only methods in production | Move to test utilities |
| Mock without understanding | Understand dependencies first, mock minimally |
| Incomplete mocks | Mirror real API structure completely |
| Tests as afterthought | TDD — tests first |
| Over-complex mocks | Consider integration tests |

## The Bottom Line

**Mocks are tools to isolate, not things to test.**

If you're testing mock behavior, you've gone wrong. Test real behavior or question why you're mocking at all.
