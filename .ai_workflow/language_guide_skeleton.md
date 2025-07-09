# [LANGUAGE_NAME] Agent Guide

This file provides comprehensive guidance for the AI Assistant when working with [LANGUAGE_NAME] applications.

## Core Development Philosophy

### KISS (Keep It Simple, Stupid)
Simplicity should be a key goal in design. Choose straightforward solutions over complex ones whenever possible. Simple solutions are easier to understand, maintain, and debug.

### YAGNI (You Aren't Gonna Need It)
Avoid building functionality on speculation. Implement features only when they are needed, not when you anticipate they might be useful in the future.

## 🤖 Assistant Guidelines

### Context Awareness
- When implementing features, always check existing patterns first
- Prefer composition over inheritance in all designs
- Use existing utilities before creating new ones
- Check for similar functionality in other domains/features

### Common Pitfalls to Avoid
- Creating duplicate functionality
- Overwriting existing tests
- Modifying core frameworks without explicit instruction
- Adding dependencies without checking existing alternatives

### Workflow Patterns
- Preferably create tests BEFORE implementation (TDD)
- Use "think hard" for architecture decisions
- Break complex tasks into smaller, testable units
- Validate understanding before implementation

## 🚀 [LANGUAGE_NAME] Key Features

[Describe key features of the language/framework, e.g., async/await, package management, core libraries.]

## 🏗️ Project Structure

[Describe typical project structure, e.g., src/, tests/, config/.]

## 📦 Package Management & Dependencies

[Describe how dependencies are managed, e.g., npm, pip, Maven, Composer.]

## 🎯 Type Safety & Annotations

[Describe type system, e.g., TypeScript, Java types, Python type hints.]

## 🛡️ Input Validation

[Describe common validation libraries/patterns, e.g., Zod, Pydantic, Bean Validation.]

## 🧪 Testing Strategy

[Describe testing frameworks, coverage requirements, test organization.]

## 🔐 Security Requirements

[Describe security best practices, e.g., input sanitization, environment variables.]

## 💅 Code Style & Quality

[Describe linters, formatters, coding conventions.]

## 📋 Pre-commit Checklist

[List common checks before committing code.]

## ⚠️ Critical Guidelines

[List 5-10 critical rules for this language/framework.]

---

*This guide is a living document. Update it as patterns evolve.*
*Last updated: [Current Date]*
