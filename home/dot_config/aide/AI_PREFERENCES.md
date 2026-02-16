# General Principles

- Write the simplest solution that solves the problem
- Read and understand existing code before making changes
- Follow existing patterns and conventions in the codebase
- Prioritize clarity and correctness over cleverness

# Code Style

## Structure
- Use explicit error handling over generic catch-all patterns
- Use early returns to reduce nesting depth
- Keep functions focused on a single responsibility
- Prefer named constants over magic numbers or strings

## Clarity
- Write self-documenting code with clear names
- Add comments only to explain "why", not "what"
- Choose descriptive names over abbreviations
- Extract complex logic into well-named functions

# Version Control

## Commits
- Use conventional commits: `type(scope): description`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`
  - Example: `feat(auth): add JWT validation`
- Keep commits atomic — one logical change per commit
- Sign all commits
- Write clear commit messages that explain the purpose

## Pull Requests
- Provide clear descriptions with context
- Include test plans or verification steps
- Reference related issues when applicable

# Testing

- Write tests alongside new functionality
- Prefer table-driven tests for multiple scenarios
- Test behavior, not implementation details
- Use descriptive names: `Test<Function>_<Scenario>_<Expected>`
- Ensure tests are repeatable and isolated

# Documentation

- Update README when adding user-facing features
- Document public APIs with doc comments
- Include usage examples for complex interfaces
- Keep documentation synchronized with code changes

# Security

- Never hardcode secrets, tokens, or credentials
- Use environment variables or secret managers
- Validate and sanitize all external input
- Follow least-privilege patterns
- Be aware of common vulnerabilities (injection, XSS, CSRF)

# Design Principles

- Prefer composition over inheritance
- Use dependency injection for testability
- Minimize external dependencies when standard library suffices
- Prefer immutable data structures where practical
- Define clear interfaces between components
