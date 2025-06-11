# Book Expert Task

An iOS application that demonstrates various features including user authentication, PDF viewing, image handling, and data management.

## Features

### 1. User Authentication
- Google Sign-In integration using Firebase Authentication
- User session management
- Core Data storage for user details

### 2. PDF Viewer
- PDF document viewing using PDFKit
- Support for the provided PDF URL
- Navigation controls for multi-page documents
- Error handling and loading states

### 3. Image Handling
- Camera integration for capturing photos
- Photo library access for selecting images
- Image preview and management
- Permission handling for camera and photo library access

### 4. Data Management
- RESTful API integration with the provided endpoint
- Core Data implementation for offline storage
- CRUD operations (Create, Read, Update, Delete)
- Search functionality
- Pull-to-refresh
- Error handling and validation

### 5. Local Notifications
- Notification support for deleted items
- Custom notification content
- Notification preferences management

## Technical Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase Authentication
- Core Data
- PDFKit
- SwiftUI

## Project Structure

The project follows MVVM architecture and is organized into the following directories:

```
BookExpertTask/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Core/
│   ├── CoreData/
│   ├── Network/
│   └── Extensions/
├── Features/
│   ├── Authentication/
│   ├── PDFViewer/
│   ├── ImageHandling/
│   ├── DataManagement/
│   └── Notifications/
├── Resources/
│   ├── Assets.xcassets
│   └── Colors.xcassets
└── Utilities/
    ├── Constants.swift
    ├── ThemeManager.swift
    └── PermissionManager.swift
```

## Setup Instructions

1. Clone the repository
2. Install dependencies using Swift Package Manager
3. Add your Firebase configuration file (GoogleService-Info.plist)
4. Build and run the project

## Dependencies

- Firebase/Auth
- PDFKit (built-in)
- SwiftUI (built-in)
- Core Data (built-in)

## Configuration

1. Firebase Setup:
   - Create a new Firebase project
   - Add an iOS app to your Firebase project
   - Download the GoogleService-Info.plist file
   - Add the file to your Xcode project

2. Google Sign-In Setup:
   - Configure your Google Sign-In credentials in the Firebase Console
   - Add the required URL schemes to your Info.plist

3. Permissions:
   - Camera Usage Description
   - Photo Library Usage Description
   - Notification Permission

## Features Implementation Details

### Authentication
- Uses Firebase Authentication for Google Sign-In
- Stores user details in Core Data for offline access
- Handles session management and sign-out

### PDF Viewer
- Implements PDFKit for document viewing
- Supports the provided PDF URL
- Includes navigation controls and error handling

### Image Handling
- Implements camera and photo library access
- Handles permissions and user authorization
- Provides image preview and management

### Data Management
- Implements RESTful API integration
- Uses Core Data for offline storage
- Provides CRUD operations with error handling
- Includes search functionality

### Notifications
- Implements local notifications for deleted items
- Handles notification permissions
- Provides notification preferences

## Theme Support

The app supports both light and dark themes with:
- Dynamic color schemes
- Custom fonts
- Consistent layout and spacing
- Adaptive UI elements

## Error Handling

The app implements comprehensive error handling for:
- Network requests
- Authentication
- File operations
- Permission requests
- Data validation

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 