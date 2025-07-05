# Create BASE PRP (Advanced)

Generate a comprehensive PRP for general feature implementation with thorough research.

## Feature: $ARGUMENTS

## Research Process

1. **Codebase Analysis**
   - Search for similar features/patterns
   - Identify files to reference in PRP
   - Note existing conventions to follow
   - Check test patterns for validation approach

2. **External Research**
   - Library documentation (include specific URLs)
   - Implementation examples (GitHub/StackOverflow)
   - Best practices and common pitfalls
   - Performance considerations

3. **User Clarification** (if needed)
   - Specific patterns to mirror?
   - Integration requirements?
   - Performance/scale requirements?
   - Security considerations?

## PRP Generation

Using PRPs/prp_base_typescript.md as template:

### Critical Context to Include

- **Documentation**: URLs with specific sections
- **Code Examples**: Real snippets from codebase
- **Gotchas**: Library quirks, version issues
- **Patterns**: Existing approaches to follow

### Implementation Blueprint

- Start with pseudocode showing approach
- Reference real files for patterns
- Include error handling strategy
- Show progressive enhancement path

### Validation Gates (Must be Executable) eg for TypeScript/Next.js

```bash
# Type checking
npm run typecheck

# Linting and formatting
npm run lint

# Unit Tests
npm test

# Build validation
npm run build
```

### Error Patterns

- Include common errors with fixes
- Debug strategies
- Rollback approaches

## User Interaction Points

1. **After Initial Research**
   - Present findings
   - Confirm scope and approach
   - Identify any missing context

2. **Before Finalizing**
   - Review implementation strategy
   - Confirm validation approach
   - Check completeness

## Output

Save as: `PRPs/{feature-name}.md`

## Quality Checklist

- [ ] All necessary context included
- [ ] Validation gates are executable by AI
- [ ] References existing patterns
- [ ] Clear implementation path
- [ ] Error handling documented

Remember: The goal is one-pass implementation success through comprehensive context.
