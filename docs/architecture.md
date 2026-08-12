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
MarbleDeviceActivityMonitor/ # Screen Time schedule and threshold callbacks
MarbleShieldAction/          # actions for the existing friction flow
MarbleShieldConfiguration/   # shield presentation for friction and focus
```

## Ownership

- `App` owns `AppRouter`, `AppRoute`, `AppRouteBuilder`, and `RootView`.
- A feature owns its models, route enum/builder, views, view models, and any feature-specific service needed by real data.
- Features do not depend directly on other features. Navigate through `AppRoute` instead.
- `Core` is reserved for generic, cross-app extensions and helpers. Create it only when such code actually exists; do not commit placeholder files or directories.
- The app and Screen Time extensions use the canonical App Group
  `group.com.lasvegas.Marblefahmi1`. The selected apps, categories, and web
  domains are property-list encoded under `saved_activity_selection`.
- The existing cumulative-usage enforcement owns the default
  `ManagedSettingsStore`, the `marble.usage.monitoring` activity, and the
  friction/recommendation shield state.
- Setup Profile may schedule `marble.focus.<weekday>` activities. Their
  callbacks own only the named `marble.focus` store and the
  `screenTime.focusWindowActive` flag. Ending a focus window must never clear
  the default store or replace the existing friction/recommendation state.

## Dependencies

Route builders compose a feature by initializer-injecting a view model and its real dependencies. Do not introduce a global singleton or dependency container.

Use Apple and Swift standard APIs first. Adding a third-party dependency requires an explicit reason and approval.
