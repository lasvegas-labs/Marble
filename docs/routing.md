# Routing

Routing is type-safe and builder-based:

```
View -> AppRouter -> AppRoute -> AppRouteBuilder -> FeatureRouteBuilder -> View
```

## Adding a feature destination

1. Add the feature case to `AppRoute`.
2. Delegate that case from `AppRouteBuilder` to the feature route builder.
3. Add the destination to the feature route enum and build it in the feature route builder.
4. From a view, call `AppRouter` with the resulting `AppRoute`.

`RootView` owns the `NavigationStack` and the global `navigationDestination`. Feature views must not construct destination views inline.

## AppRouter contract

- `push(_:)` appends a stack route.
- `pop()` removes the final route when one exists.
- `popToRoot()` clears every route in the stack.
- `replace(with:)` replaces the final route, or pushes when the stack is empty.
- `presentSheet(_:)` presents one optional `AppRoute` as a sheet.
- `dismissSheet()` clears the active sheet route.

The same `AppRoute` and `AppRouteBuilder` are used for stack and sheet destinations. `AppRoute` is `Hashable` and `Identifiable` so `RootView` can use value navigation and `.sheet(item:)`.

Only stack navigation and sheets are supported now. Do not add full-screen covers, deep links, or state restoration until a product requirement exists.
