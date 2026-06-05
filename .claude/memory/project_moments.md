---
name: project-moments
description: Moments iOS app — local-first photo moments app built with SwiftUI + SwiftData
metadata:
  type: project
---

This is a SwiftUI iOS app called "Moments" — a local-first photo moments app.

**Why:** User wants a private, no-backend app to collect memories as Moments and export them to Apple Photos albums.

**Tech stack:**
- Swift 6, SwiftUI, SwiftData, PhotosUI, PhotoKit
- Minimum deployment: iOS 17
- No backend, no auth, no external services
- Project generated with xcodegen from `project.yml`

**Architecture:** MVVM, clean folder separation:
- `Models/` — Moment.swift, MomentPhoto.swift (SwiftData @Model classes)
- `Views/` — 6 views
- `ViewModels/` — MomentListViewModel, MomentDetailViewModel (@Observable)
- `Services/` — ImageLoadingService (actor), PhotoLibraryService, PhotoExportService
- `Components/` — Reusable SwiftUI views
- `Utilities/` — DateFormatter+App, PermissionHelpers

**How to apply:** When adding features, follow this structure. Run `xcodegen generate` after adding new source files to update the Xcode project.

**Known issue on this machine:** `actool` asset catalog compilation fails for simulator builds because SDK is 26.5 but only runtimes 26.0/26.1 are installed. Use Xcode GUI to build — it works fine there. Swift typecheck passes cleanly.
