# Momento

Momento is a local-first iOS app for collecting personal photo moments. Users can create their own moments, add photos from Apple Photos, set cover images, mark favorite photos, and export selected images directly into an album in Apple Photos.

The app is intentionally built locally. There is no account, no backend, and no cloud connection. All data stays on the device.

---

## Idea

Beautiful memories often get lost in the regular Photos app. Momento helps users collect special days, trips, holidays, birthdays, events, or small everyday memories in a more personal and structured way.

A moment contains a title, date, description, and related photos. The best photos can be marked as favorites. If needed, the whole moment or only the favorite photos can be exported into a real Apple Photos album.

---

## Main Features

- Create, edit, and delete moments
- Save title, date, and description for each moment
- Select photos from Apple Photos
- Display photos in a grid
- Open photos in a detail view
- Set a cover image for a moment
- Mark photos as favorites
- Remove photos from a moment
- Export all photos of a moment into Apple Photos
- Export only favorite photos into Apple Photos
- Edit the album name before export
- Local storage with SwiftData
- Privacy-friendly usage without backend or login

---

## Version 1.0 Scope

The first version focuses on fully local usage.

Included in Version 1.0:

- Local moments
- Local persistence
- Apple Photos selection
- Apple Photos export
- Favorite photos
- Cover images
- Settings
- Privacy information

Not included in Version 1.0:

- Login
- Backend
- Shared groups
- Device-to-device sync
- iCloud sync
- Push notifications
- In-app purchases
- Ads

---

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- PhotosPicker
- PhotoKit
- UserDefaults / AppStorage
- SF Symbols

---

## Architecture

The app is split into clear areas:

```text
Momento/
├── App/
│   └── MomentoApp.swift
├── Models/
│   ├── Moment.swift
│   └── MomentPhoto.swift
├── Views/
│   ├── MomentListView.swift
│   ├── MomentDetailView.swift
│   ├── MomentFormView.swift
│   ├── PhotoDetailView.swift
│   └── SettingsView.swift
├── ViewModels/
│   ├── MomentListViewModel.swift
│   └── MomentDetailViewModel.swift
├── Services/
│   ├── PhotoLibraryService.swift
│   ├── PhotoExportService.swift
│   └── ImageLoadingService.swift
├── Components/
│   ├── MomentCardView.swift
│   ├── PhotoGridView.swift
│   ├── EmptyStateView.swift
│   └── PrimaryButton.swift
└── Utilities/
    ├── DateFormatter+App.swift
    └── PermissionHelpers.swift
```

---

## Data Model

### Moment

A moment is a personal photo collection.

```swift
Moment
- id: UUID
- title: String
- date: Date
- momentDescription: String
- coverPhotoId: UUID?
- createdAt: Date
- updatedAt: Date
- photos: [MomentPhoto]
```

### MomentPhoto

A `MomentPhoto` is a reference to an image from Apple Photos.

```swift
MomentPhoto
- id: UUID
- localIdentifier: String
- isFavorite: Bool
- addedAt: Date
- moment: Moment?
```

Important: Momento does not store full image files in SwiftData. It only stores references to photos from Apple Photos.

---

## Use Cases

### UC1: Create Moment

The user can create a new moment with a title, date, and optional description.

### UC2: Edit Moment

The user can edit the title, date, and description of an existing moment.

### UC3: Delete Moment

The user can delete a moment. Only local Momento data is removed. Original photos in Apple Photos remain untouched.

### UC4: Show Moments

All saved moments are displayed in an overview.

### UC5: Show Moment Detail

The user can open a moment and view its details, description, and photos.

### UC6: Select Photos

The user can select multiple photos from Apple Photos and add them to a moment.

### UC7: Set Cover Image

A photo can be set as the cover image of a moment.

### UC8: Mark Photo as Favorite

Special photos can be marked as favorites.

### UC9: Remove Photo from Moment

A photo can be removed from a moment without deleting it from Apple Photos.

### UC10: Show Photo Fullscreen

A photo can be opened in a larger detail view.

### UC11: Export Moment to Apple Photos

All photos of a moment can be exported into a new or existing Apple Photos album.

### UC12: Export Favorites Only

Only photos marked as favorites can be exported.

### UC13: Edit Album Name

Before exporting, the user can edit the target Apple Photos album name.

### UC14: Manage Photo Permissions

The app handles full, limited, and denied photo access in a clear and understandable way.

### UC15: Show Settings

The user can view app information, privacy information, and edit the default album prefix.

---

## Privacy

Momento is built local-first.

This means:

- There is no account.
- There is no backend.
- No data is sent to external servers.
- Photos are only accessed when the user actively selects them.
- Exporting to Apple Photos only happens after an active user action.
- Deleted moments do not remove original photos from Apple Photos.

---

## Apple Photos Access

Momento uses Apple APIs to safely select and export photos.

Used frameworks:

- `PhotosUI` for `PhotosPicker`
- `Photos` for `PhotoKit`

Required permissions in `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Momento needs access to your photos so you can add images to your moments.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Momento needs permission to save photos into Apple Photos albums.</string>
```

---

## Export Behavior

When exporting, Momento creates an Apple Photos album with a name like:

```text
Momento – Summer Evening at the Lake
```

The user can edit the name before exporting.

Export options:

- Export all photos
- Export favorites only

If some photos are no longer available, Momento shows a clear message and exports the remaining available photos.

---

## Installation and Development

### Requirements

- macOS
- Xcode
- iOS Simulator or physical iPhone
- Apple Developer Account for TestFlight and App Store release

### Run the Project

1. Open the project in Xcode
2. Select a signing team
3. Check the bundle identifier
4. Run the app on a simulator or iPhone

---

## App Store Preparation

Before release, the following items need to be completed:

- Create app icon
- Check launch screen
- Create App Store screenshots
- Prepare privacy text
- Provide a support URL
- Write App Store description
- Upload TestFlight build
- Fill in App Review information

---

## Possible Future Features

Future versions could include:

- iCloud sync
- Shared moments with friends
- Invitation system
- Memory flashbacks
- Yearly recap
- Search
- Tags and categories
- Map view for locations
- Widgets
- Export as ZIP or PDF
- Face ID protection for private moments

---

## Project Goal

The goal of Momento is to build a personal, beautiful, and privacy-friendly iOS app that is useful in everyday life and also works well as a portfolio project.

The app should start small, but be built with a clean structure so it can be extended later.
