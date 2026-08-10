# Code Conventions

Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and these project rules:

- Use English names for types, functions, files, and documentation.
- Keep a type in the layer and feature that owns it; do not create cross-feature imports.
- Prefer small value types and direct initializer injection over singletons, factories, or containers.
- Keep view-owned `@State` and `@StateObject` properties `private`.
- Use `Button` for tappable controls and use system text styles or Dynamic Type-aware custom fonts.
- Use dedicated accessibility modifiers when a default label is unclear; hide purely decorative images from accessibility.
- Prefer Swift and Apple frameworks. Propose any new dependency before adding it.

Do not add abstractions, configuration, services, or shared code before there is a current use for them.
