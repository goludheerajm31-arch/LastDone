# LastDone

> A minimalist native iOS utility to track when you last performed everyday activities.

**LastDone** is designed to feel completely at home in Apple’s ecosystem—built as if it were a clean, focused Apple utility rather than an overloaded productivity suite. 

No gamification. No streaks. No motivational notifications. Just simple, beautiful, native tracking of what matters.

---

## Examples

- **Haircut** — 18 days ago
- **Bedsheets** — 6 days ago
- **Clean shoes** — 12 days ago
- **Change toothbrush** — 71 days ago

---

## Design Principles

- **Extremely Minimal**: Content-first layout with zero visual clutter.
- **Zero Unnecessary Noise**: No onboarding carousels, dashboards, statistics, or badges.
- **Familiar iOS Interactions**: Native navigation, swipe actions, context menus, and native sheets.
- **Apple Visual Language**: SF Pro typography, Dynamic Type, semantic system colors, and native Light/Dark mode support.
- **120 FPS Responsiveness**: Asynchronous disk persistence and equatable view diffing for fluid interactions.

---

## Features

- **Home Screen**:
  - Clean list of tracked activities displaying activity name and relative elapsed time.
  - Quick action: Swipe leading right to mark **"Done Today"**.
  - Swipe trailing left to **Delete**.
  - Long-press context menu for quick actions (Done Today, Edit, Delete).
  - Navigation bar `+` button to add new activities.
- **Minimal Detail View**:
  - Displays activity name, prominent relative time, and exact completion date.
  - Large primary **"Done Today"** button with native haptic feedback.
  - "Edit" button to change activity details or delete.
- **Native Add & Edit Sheets**:
  - Fast modal forms with autofocus and native date pickers.
- **Reliable Local Persistence**:
  - 100% offline, local JSON persistence with atomic background saves. Zero network or account dependencies.

---

## Architecture & Codebase

The app is built using clean, idiomatic SwiftUI with zero third-party dependencies:

```
LastDone/
├── LastDoneApp.swift              // App entry point (@main)
├── Models/
│   └── Activity.swift             // Identifiable, Codable model (id, name, lastCompletedAt)
├── Store/
│   └── ActivityStore.swift        // ObservableObject handling state & async JSON storage
├── Utilities/
│   └── RelativeDateFormatter.swift// Calendar calculations ("Today", "Yesterday", "X days ago")
└── Views/
    ├── ActivityListView.swift     // Home screen navigation & list
    ├── ActivityRowView.swift      // Individual activity row
    ├── ActivityDetailView.swift   // Detail screen with large relative time & primary action
    └── ActivityEditSheet.swift    // Native Form sheet for adding/editing
```

---

## Requirements

- **iOS**: 17.0+
- **Xcode**: 15.0+ (Tested up to Xcode 16 / Swift 6)
- **Frameworks**: SwiftUI, Foundation, Combine

---

## Getting Started

### Open in Xcode

1. Open the project in Xcode:
   ```bash
   open LastDone.xcodeproj
   ```
2. Select any iPhone simulator (e.g., **iPhone 17 Pro** or **iPhone 16**).
3. Press **`⌘ + R`** to build and run.

### Run from Terminal

```bash
# 1. Boot simulator
xcrun simctl boot "iPhone 17 Pro" || true
open -a Simulator

# 2. Build app
xcodebuild -project LastDone.xcodeproj \
           -scheme LastDone \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           -derivedDataPath ./build/DerivedData \
           CODE_SIGNING_ALLOWED=NO build

# 3. Install and launch
xcrun simctl install booted ./build/DerivedData/Build/Products/Debug-iphonesimulator/LastDone.app
xcrun simctl launch booted com.lastdone.LastDone
```

---

## Running Unit Tests

To run the automated test suite:

- In Xcode: Press **`⌘ + U`**
- From Terminal:
  ```bash
  xcodebuild -project LastDone.xcodeproj \
             -scheme LastDone \
             -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
             -derivedDataPath ./build/DerivedData \
             CODE_SIGNING_ALLOWED=NO test
  ```

---

## License

MIT License. Feel free to use and adapt.
