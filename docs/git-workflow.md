# Git Workflow

Use one descriptive branch per change:

```
feature/<topic>
fix/<topic>
docs/<topic>
chore/<topic>
```

Use Conventional Commits with a required scope:

```
type(scope): imperative subject
```

Examples:

```
feat(home): add profile header
fix(router): clear the navigation stack
docs(architecture): define feature ownership
```

Keep commits focused. A pull request or handoff should state the user-visible outcome, the affected feature or contract, and the build result. Update the harness only when the documented contract changes.
