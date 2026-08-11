# Architecture

Marble is a feature-first SwiftUI application.

```
Marble/
  App/                 # app composition and global navigation
  Features/
    <Feature>/
      Model/
      Router/
      Service/            # optional feature-owned Apple/system integrations
      View/
      ViewModel/
  Core/                # future generic extensions and helpers only
MarbleDeviceActivityMonitor/ # Screen Time enforcement extension
```

## Ownership

- `App` owns `AppRouter`, `AppRoute`, `AppRouteBuilder`, and `RootView`.
- A feature owns its models, route enum/builder, views, view models, and any feature-specific service needed by real data.
- Features do not depend directly on other features. Navigate through `AppRoute` instead.
- `Core` is reserved for generic, cross-app extensions and helpers. Create it only when such code actually exists; do not commit placeholder files or directories.
- The app and Device Activity extension share only opaque Screen Time selections through their configured App Group.

## Dependencies

Route builders compose a feature by initializer-injecting a view model and its real dependencies. Do not introduce a global singleton or dependency container.

Use Apple and Swift standard APIs first. Adding a third-party dependency requires an explicit reason and approval.
