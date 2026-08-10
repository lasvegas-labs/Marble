# Feature Development

Every feature follows MVVM and is organized under `Features/<Feature>`.

```
Features/Profile/
  Model/
  Router/
    ProfileRoute.swift
    ProfileRouteBuilder.swift
  View/
    ProfileView.swift
  ViewModel/
    ProfileViewModel.swift
```

## Layer responsibilities

- `Model` contains feature-owned data types. Add a service or repository here only when the feature has a real data source.
- `Router` declares feature destinations and builds the destination views.
- `View` renders state, forwards user intent to its view model, and dispatches navigation through `AppRouter`.
- `ViewModel` owns presentation state and feature logic. It does not receive or call `AppRouter`.

## Composition

Route builders create the view model and inject it into the view. A view that owns its injected `ObservableObject` stores it as a private `@StateObject`.

```swift
case .main:
    ProfileView(viewModel: ProfileViewModel())
```

Do not add empty layers, repositories, or shared abstractions for anticipated work.
