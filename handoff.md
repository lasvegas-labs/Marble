# Handoff: Report Feature — Marble iOS App

## Context

Marble is a **feature-first SwiftUI iOS app** for screen time tracking. We're adding a **Report tab** showing time impact data. Steps 1–3 are done. Steps 4–6 remain.

---

## Project Rules (MUST follow)

1. Read [AGENTS.md](file:///Users/jordan/Documents/Marble/AGENTS.md) and all docs in [docs/](file:///Users/jordan/Documents/Marble/docs/) before changing code
2. **Never build Xcode projects** — only create/edit Swift files
3. **No third-party dependencies** without explicit approval
4. Prefer Swift/Apple frameworks
5. Keep changes within the owning feature
6. **MVVM pattern** per [feature-development.md](file:///Users/jordan/Documents/Marble/docs/feature-development.md)
7. **Routing** per [routing.md](file:///Users/jordan/Documents/Marble/docs/routing.md)
8. **Code conventions** per [code-conventions.md](file:///Users/jordan/Documents/Marble/docs/code-conventions.md)
9. **Ponytail full mode**: YAGNI everything. No unrequested abstractions. Minimum that works.
10. **Caveman full mode**: Terse responses. No fluff.

---

## Architecture

```
Marble/
  App/                          # AppRouter, AppRoute, AppRouteBuilder, RootView
  Features/
    Home/                       # Existing feature (MVVM)
      Model/  Router/  View/  ViewModel/
    Report/                     # NEW feature (partially built)
      Model/  Router/  View/  ViewModel/
    Onboarding/                 # Existing feature
      Model/  Router/  View/  ViewModel/
```

### Key patterns (copy exactly from Home feature):
- `@StateObject private var viewModel` in views, injected via init
- Route enum → RouteBuilder → builds View with ViewModel
- AppRoute delegates to feature RouteBuilder
- Views use `@EnvironmentObject private var router: AppRouter` for navigation
- ViewModel is `ObservableObject`, does NOT call AppRouter

---

## Completed (Steps 1–3)

### Model files created:

**[ScreenTimeData.swift](file:///Users/jordan/Documents/Marble/Marble/Features/Report/Model/ScreenTimeData.swift)**
```swift
struct DailyScreenTime: Identifiable  // day, dayNumber, hours, isHighlighted
struct AppUsageEntry: Identifiable     // appName, iconName, duration
struct ActivitySuggestion: Identifiable // iconName, title, subtitle
```

**[GradeLevel.swift](file:///Users/jordan/Documents/Marble/Marble/Features/Report/Model/GradeLevel.swift)**
```swift
enum GradeLevel: String, CaseIterable  // .a/.b/.c/.d
  var range: String                     // "≤ 20 hours/week" etc.
  static func grade(for hours: Double)  // maps hours → grade
```

### Router files created:

**[ReportRoute.swift](file:///Users/jordan/Documents/Marble/Marble/Features/Report/Router/ReportRoute.swift)**
```swift
enum ReportRoute: Hashable { case main }
```

**[ReportRouteBuilder.swift](file:///Users/jordan/Documents/Marble/Marble/Features/Report/Router/ReportRouteBuilder.swift)**
```swift
struct ReportRouteBuilder {
    static func build(_ route: ReportRoute) -> some View
    // case .main: ReportView(viewModel: ReportViewModel())
}
```

### ViewModel created:

**[ReportViewModel.swift](file:///Users/jordan/Documents/Marble/Marble/Features/Report/ViewModel/ReportViewModel.swift)**
```swift
final class ReportViewModel: ObservableObject
  @Published var weeklyTotalSeconds: TimeInterval  // 19h 18m
  @Published var dailyData: [DailyScreenTime]       // 7 days
  @Published var appUsage: [AppUsageEntry]           // 6 apps
  @Published var suggestions: [ActivitySuggestion]   // 4 suggestions
  @Published var showGradeTooltip: Bool
  var grade: GradeLevel                              // computed
  var weeklyTotalHours: Double                       // computed
  var formattedWeeklyTotal: String                   // "19h 18m"
  func formattedDuration(_ duration: TimeInterval) -> String
```

---

## Remaining Work

### Step 4: Views (6 NEW files)

All go under `Marble/Features/Report/View/`

#### 4a. [NEW] `ReportView.swift`
Main scrollable page. Structure (top to bottom):
1. Navigation bar: back chevron + "Time Impact" title + "See the real cost of your screen time" subtitle
2. `TimeImpactCardView` — weekly total + grade
3. "Instead, you could have . . ." header + `ForEach` of `ActivitySuggestionView`
4. "Time Spend" header + week range pills (1-7, 8-14, 15-21, 22-30) + `WeeklyChartView`
5. "Detail Screen Usage" header + `ForEach` of `AppUsageRowView`

```swift
struct ReportView: View {
    @StateObject private var viewModel: ReportViewModel
    init(viewModel: ReportViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    // ScrollView with VStack sections
}
```

#### 4b. [NEW] `TimeImpactCardView.swift`
Rounded card showing:
- Left: "Weekly you spent" label + large "19h 18m"
- Right: "Your Grade:" label + large circled "A" letter (teal)
- Tapping grade triggers `viewModel.showGradeTooltip = true`
- `.popover(isPresented:)` shows `GradeTooltipView`

#### 4c. [NEW] `ActivitySuggestionView.swift`
Single row: SF Symbol icon (in rounded square) + title + subtitle
- Background: white/system card with subtle corner radius
- All 4 items in a rounded card container

#### 4d. [NEW] `WeeklyChartView.swift`
Uses **Swift Charts** (`import Charts`) — Apple framework, already available:
- `Chart { ForEach(data) { BarMark(...) } }`
- X axis: day numbers (1–7)
- Y axis: hidden
- Bar color: teal accent `Color(red: 0.18, green: 0.83, blue: 0.75)` — hex `#2DD4BF`
- Annotation on tallest bar showing hours
- Below chart: "Most Distracting: Tuesday" / "Most Productive: Wednesday" labels

#### 4e. [NEW] `AppUsageRowView.swift`
Single row: SF Symbol icon + app name + horizontal progress bar (teal) + duration label
- Progress bar width proportional to max duration in the list
- Pass `maxDuration` from parent for proportion calculation

#### 4f. [NEW] `GradeTooltipView.swift`
Popover/sheet content:
- "Scoring level" title (bold)
- List of all `GradeLevel.allCases` showing: "Grade A : ≤ 20 hours/week"
- "Close" button at bottom

---

### Step 5: App Integration (3 MODIFIED files)

#### 5a. [MODIFY] [AppRoute.swift](file:///Users/jordan/Documents/Marble/Marble/App/AppRoute.swift)
Add `case report(ReportRoute)` to the enum:
```swift
enum AppRoute: Hashable, Identifiable {
    case home(HomeRoute)
    case report(ReportRoute)  // ADD THIS
    var id: Self { self }
}
```

#### 5b. [MODIFY] [AppRouteBuilder.swift](file:///Users/jordan/Documents/Marble/Marble/App/AppRouteBuilder.swift)
Add case to switch:
```swift
case .report(let reportRoute):
    ReportRouteBuilder.build(reportRoute)
```

#### 5c. [MODIFY] [RootView.swift](file:///Users/jordan/Documents/Marble/Marble/App/RootView.swift)
Replace bare `NavigationStack` with `TabView` containing 2 tabs. Each tab gets own `NavigationStack`:

```swift
TabView {
    // Home tab
    NavigationStack(path: $router.path) {
        // existing home content (onboarding check + HomeRouteBuilder)
        .navigationDestination(for: AppRoute.self) { route in
            AppRouteBuilder.build(route)
        }
    }
    .tabItem {
        Label("Home", systemImage: "house.fill")
    }

    // Report tab
    NavigationStack {
        ReportRouteBuilder.build(.main)
    }
    .tabItem {
        Label("Report", systemImage: "chart.bar.fill")
    }
}
.sheet(item: $router.presentedSheet) { route in
    AppRouteBuilder.build(route)
}
```

> [!WARNING]
> The current router uses a single `path` array. With TabView, only the Home tab should bind to `router.path`. Report tab has no push navigation yet — just shows `.main`.

---

### Step 6: Verify

- Ensure all files compile (no Xcode build — just review for syntax/type errors)
- Check all imports present (`Charts`, `SwiftUI`, `Combine`)
- Verify feature structure matches `Features/<Feature>/{Model,Router,View,ViewModel}`

---

## Design Tokens (from screenshot)

| Token | Value |
|---|---|
| Accent color | `Color(red: 0.18, green: 0.83, blue: 0.75)` — teal #2DD4BF |
| Card background | `Color(.systemBackground)` |
| Card corner radius | 16pt |
| Pill corner radius | 8pt |
| Section spacing | 16pt |
| Inner padding | 12–16pt |
| Card shadow | `color: .black.opacity(0.08), radius: 8, y: 2` |
| Typography | System text styles: `.largeTitle`, `.headline`, `.subheadline`, `.caption` |

## HIG Rules Applied

- SF Symbols: filled variants for tab bar icons
- Swift Charts: `BarMark` with accessibility labels
- System semantic colors (`label`, `secondaryLabel`, `systemBackground`)
- Dynamic Type: use system text styles only
- Popover for grade tooltip (adapts to sheet on iPhone)
- No custom animations beyond SwiftUI defaults
- `@Environment(\.accessibilityReduceMotion)` already handled in MarbleApp.swift

## Screenshot Reference

The Report page matches this layout (top to bottom):
1. "Time Impact" header with back arrow
2. Card: "Weekly you spent 19h 18m" + Grade "A" circle
3. "Instead, you could have..." — 4 activity rows in a card
4. "Time Spend" — "August" label + week pills + bar chart (7 bars, teal)
5. "Most Distracting: Tuesday" / "Most Productive: Wednesday"
6. "Detail Screen Usage" — 6 app rows with progress bars
7. Tab bar: Home | Report (selected) | Settings (NOT included yet)
