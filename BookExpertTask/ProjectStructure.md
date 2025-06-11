# BookExpertTask Project Structure

```
BookExpertTask/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Core/
│   ├── CoreData/
│   │   ├── BookExpertTask.xcdatamodeld
│   │   ├── CoreDataManager.swift
│   │   └── Models/
│   ├── Network/
│   │   ├── NetworkManager.swift
│   │   └── APIEndpoints.swift
│   └── Extensions/
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── PDFViewer/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── ImageHandling/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── DataManagement/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   └── Notifications/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Colors.xcassets
└── Utilities/
    ├── Constants.swift
    ├── ThemeManager.swift
    └── PermissionManager.swift
```

## Dependencies (Swift Package Manager)

- Firebase/Auth (for Google Sign-In)
- PDFKit (for PDF viewing)
- SDWebImage (for image handling)
- SwiftLint (for code quality)

## Features Implementation Plan

1. **Authentication**
   - Google Sign-In integration
   - User session management
   - Core Data storage for user details

2. **PDF Viewer**
   - PDFKit implementation
   - Custom PDF viewer UI
   - Error handling for PDF loading

3. **Image Handling**
   - Camera integration
   - Photo library access
   - Image preview and storage
   - Permission handling

4. **Core Data & API Integration**
   - RESTful API integration
   - CRUD operations
   - Offline data management
   - Error handling and validation

5. **Local Notifications**
   - Notification management
   - Custom notification content
   - Notification preferences

6. **Theme Support**
   - Light/Dark mode implementation
   - Custom color schemes
   - Dynamic theme switching

7. **Permissions**
   - Camera access
   - Photo library access
   - Notification permissions 