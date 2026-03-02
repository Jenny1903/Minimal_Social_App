# Fello 🌟

A minimal and elegant social media mobile application built with Flutter and Firebase. Connect, share, and engage with your circle in a beautifully crafted interface that prioritizes simplicity and user experience.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)
![Version](https://img.shields.io/badge/Version-1.0.0-orange)

## 📖 About

Fello is a modern, minimalist social media application designed for meaningful connections. Built with Flutter and Firebase, it offers a seamless cross-platform experience with beautiful animations, real-time updates, and an intuitive interface inspired by contemporary design patterns.

## ✨ Features

### 🎯 Phase 1 - Core Features (COMPLETED)

#### Authentication & Security
- 🔐 **Secure Authentication** - Firebase Auth with email/password
- 👤 **User Profiles** - UID-based user system with profiles
- 🔒 **Password Management** - Reset password via email
- 🗑️ **Account Deletion** - Complete data cleanup on account deletion

#### Posts & Content
- 📱 **Rich Posts** - Create posts with text and multiple images
- 🖼️ **Image Upload** - Multi-image support with Firebase Storage
- ✏️ **Edit Posts** - Update your own posts
- 🗑️ **Delete Posts** - Remove posts with full subcollection cleanup
- 📷 **Image Grid Display** - Beautiful grid layout for multiple images
- ⏱️ **Smart Timestamps** - Relative time display (e.g., "2h ago", "3d ago")

#### Social Interactions
- ❤️ **Like System** - Like posts with real-time updates
- 💬 **Comments** - Full-featured commenting system
- 👥 **Follow System** - Follow/unfollow users
- 👀 **Who Liked** - View list of users who liked a post
- 📊 **User Stats** - Post count, likes received, followers, following

#### Profile Management
- 🖼️ **Profile Pictures** - Upload and change profile pictures
- ✏️ **Edit Profile** - Update username, bio, and photo
- 📝 **Bio Support** - Add personal bio (150 characters)
- ✅ **Input Validation** - Username length and character validation
- ⚠️ **Unsaved Changes Warning** - Prevents accidental data loss

#### Settings & Account
- ⚙️ **Settings Page** - Comprehensive account management
- 🔓 **Logout** - Secure sign out functionality
- 📧 **Email-based Password Reset** - Change password securely
- 🗑️ **Account Deletion** - Permanently delete account with confirmation
- 📊 **Account Overview** - View your stats at a glance

#### User Experience
- 🌓 **Theme Support** - Beautiful light and dark modes
- 🎨 **Smooth Animations** - Fluid transitions and Lottie animations
- 📱 **Responsive Design** - Works on all screen sizes
- ⚡ **Real-time Updates** - Riverpod state management with Firebase streams
- 🔄 **Loading States** - Consistent loading indicators throughout app
- ❌ **Error Handling** - User-friendly error messages
- ✨ **Empty States** - Helpful messages when no content exists

### 🚧 Phase 2 - Coming Soon

- 🔍 **Search Functionality** - Find users and posts
- 🔔 **Notifications** - Real-time activity alerts
- 🖼️ **Image Viewer** - Full-screen image gallery with swipe
- ↓ **Pull to Refresh** - Refresh feed with swipe gesture
- ♾️ **Infinite Scroll** - Pagination for large datasets
- #️⃣ **Hashtags** - Tag and discover content
- 🌙 **Theme Toggle** - Switch between light/dark modes
- 📌 **Saved Posts** - Bookmark favorite posts

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your system:

- **Flutter SDK**: 3.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: 3.0 or higher (comes with Flutter)
- **Android Studio** or **Xcode** for mobile development
- **Firebase Account** - [Create Firebase Project](https://console.firebase.google.com/)
- **Git** for version control
- A code editor (**VS Code**, **Android Studio**, or **IntelliJ IDEA**)

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add Project" and follow the setup wizard

2. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password sign-in method
   - **Firestore Database**: Create database in production or test mode
   - **Storage**: Enable Firebase Storage for image uploads

3. **Add Firebase to your Flutter app**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your Flutter project
   flutterfire configure
   ```

4. **Set up Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       
       match /Users/{userId} {
         allow read: if true;
         allow update: if request.auth != null && request.auth.uid == userId;
         allow create: if request.auth != null;
         allow delete: if request.auth != null && request.auth.uid == userId;
       }
       
       match /Posts/{postId} {
         allow read: if true;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && 
                                 request.auth.uid == resource.data.userId;
         
         match /Likes/{likeId} {
           allow read: if true;
           allow write: if request.auth != null;
         }
         
         match /Comments/{commentId} {
           allow read: if true;
           allow create: if request.auth != null;
           allow delete: if request.auth != null && 
                          request.auth.uid == resource.data.userId;
         }
       }
     }
   }
   ```

5. **Set up Storage Rules**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jenny1903/Minimal_Social_App
   cd fello
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   flutterfire configure
   ```

4. **Check Flutter setup**
   ```bash
   flutter doctor
   ```

5. **Run the app**

   For Android:
   ```bash
   flutter run
   ```

   For iOS (macOS only):
   ```bash
   flutter run -d ios
   ```

   For a specific device:
   ```bash
   flutter devices
   flutter run -d <device_id>
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🏗️ Project Structure

```
lib/
├── auth/                   # Authentication screens
│   ├── auth.dart          # Auth wrapper
│   └── login_or_register.dart
├── Pages/                  # Main application screens
│   ├── home_page.dart     # Main feed
│   ├── profile_page.dart  # Current user profile
│   ├── user_profile_page.dart  # Other users' profiles
│   ├── edit_profile_page.dart  # Profile editing
│   ├── settings_page.dart      # App settings
│   ├── users_page.dart    # User discovery
│   └── loading_page.dart  # Splash/loading screen
├── components/            # Reusable UI components
│   ├── my_drawer.dart    # Navigation drawer
│   ├── my_textfield.dart # Custom text input
│   ├── my_post_button.dart    # Post button widget
│   ├── my_list_tile.dart      # Post card widget
│   └── who_liked_sheet.dart   # Likes bottom sheet
├── providers/             # State management (Riverpod)
│   ├── auth_provider.dart     # Authentication state
│   └── posts_provider.dart    # Posts state & service
├── services/              # Business logic & API calls
│   ├── image_service.dart     # Image upload/storage
│   ├── comments_service.dart  # Comments CRUD
│   └── database.dart          # Legacy database helper
├── routes/                # Navigation configuration
│   └── app_routes.dart   # Route definitions
├── theme/                 # App theming
│   ├── dark_mode.dart    # Dark theme
│   └── light_mode.dart   # Light theme
├── firebase_options.dart  # Firebase configuration
└── main.dart             # App entry point
```

## 📦 Key Dependencies

### Core Firebase
```yaml
firebase_core: ^2.24.2              # Firebase core SDK
firebase_auth: ^4.16.0              # Authentication
cloud_firestore: ^4.14.0            # NoSQL database
firebase_storage: ^11.6.0           # File storage
```

### State Management
```yaml
flutter_riverpod: ^2.4.9            # State management
riverpod_annotation: ^2.3.3         # Code generation for Riverpod
```

### UI/UX & Animations
```yaml
lottie: ^3.1.2                      # Complex animations
cached_network_image: ^3.3.1        # Image caching & loading
```

### Utilities
```yaml
image_picker: ^1.0.7                # Pick images from gallery/camera
intl: ^0.18.1                       # Internationalization & formatting
```

See complete list in [pubspec.yaml](pubspec.yaml)

## 🗄️ Database Schema

### Users Collection
```javascript
Users/{userId}
{
  uid: string,              // User ID (document ID)
  username: string,         // Display name
  email: string,            // User email
  bio: string,              // User bio (150 chars max)
  profilePicture: string?,  // Profile photo URL (optional)
  followers: array,         // Array of user IDs
  following: array,         // Array of user IDs
  createdAt: timestamp,     // Account creation
  updatedAt: timestamp      // Last update
}
```

### Posts Collection
```javascript
Posts/{postId}
{
  userId: string,           // Post author ID
  username: string,         // Author username
  PostMessage: string,      // Post content
  images: array?,           // Image URLs (optional)
  TimeStamp: timestamp,     // Post creation time
  likeCount: number,        // Total likes
  commentCount: number,     // Total comments
  updatedAt: timestamp?     // Last edit time
}

// Subcollections
Posts/{postId}/Likes/{userId}
{
  userId: string,
  username: string,
  userEmail: string,
  timestamp: timestamp
}

Posts/{postId}/Comments/{commentId}
{
  userId: string,
  username: string,
  text: string,
  timestamp: timestamp
}
```

## 🎨 Design System

### Color Palette
**Light Mode:**
- Primary: `#FFFFFF`
- Secondary: `#E0E0E0`
- Accent: `#667eea`
- Text: `#1A1A1A`

**Dark Mode:**
- Primary: `#121212`
- Secondary: `#1E1E1E`
- Accent: `#667eea`
- Text: `#FFFFFF`

### Typography
- **Font Family**: System default (San Francisco on iOS, Roboto on Android)
- **Heading**: 20-24px, Weight 600-700
- **Body**: 14-16px, Weight 400
- **Caption**: 12-13px, Weight 300

### Animation Principles
- Smooth transitions (200-300ms)
- Spring animations for interactive elements
- Shimmer effects for loading states
- Fade animations for content appearance

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **State Management** | Riverpod |
| **Image Handling** | Firebase Storage + Image Picker |
| **Caching** | Cached Network Image |
| **Animations** | Lottie, Flutter Animations |

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Check Code Coverage
```bash
flutter test --coverage
```

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit** your changes
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push** to the branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open** a Pull Request

### Contribution Guidelines
- Follow Flutter style guide and best practices
- Use Riverpod for state management
- Write meaningful commit messages
- Add comments for complex logic
- Test your changes thoroughly
- Update documentation if needed
- Follow the existing code structure

## 🐛 Bug Reports & Feature Requests

Found a bug or have a feature idea? Please create an issue:

1. Go to the [Issues](https://github.com/jenny1903/Minimal_Social_App/issues) tab
2. Click "New Issue"
3. Choose the appropriate template
4. Fill in the details with:
   - Clear description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Screenshots if applicable
   - Device/OS information
5. Submit!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License - Feel free to use this project for learning or commercial purposes
```

## 👨‍💻 Author

**Stuti Patel**

- 📧 Email: jennyberry1330@gmail.com
- 🐙 GitHub: [@Jenny1903](https://github.com/jenny1903)
- 💼 LinkedIn: [Stuti Patel](https://linkedin.com/in/patelstutii)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for excellent backend services
- Riverpod for clean state management
- The open-source community for incredible packages
- All contributors who help improve Fello

## 📊 Development Roadmap

### ✅ Phase 1 - Core Foundation (COMPLETED)
- Authentication system
- Posts with images
- Like & comment system
- User profiles
- Follow system
- Profile editing
- Settings & account management

### 🚧 Phase 2 - Enhanced UX (In Progress)
- Search functionality
- Notifications
- Image viewer
- Pull to refresh
- Pagination
- Hashtags
- Theme toggle

### 📅 Phase 3 - Advanced Features (Planned)
- Stories (24hr content)
- Direct messaging
- Group chats
- Video posts
- Post sharing

### 🔮 Phase 4 - Performance & Scale (Planned)
- Image compression
- Offline support
- Cloud Functions
- Analytics
- Crash reporting

### 💰 Phase 5 - Monetization (Future)
- Premium subscriptions
- Verified badges
- Ad integration

## 📞 Support & Community

Need help or want to discuss ideas?

- 📧 Email: jennyberry1330@gmail.com
- 💬 GitHub Discussions: [Coming Soon]
- 🐛 Issues: [Report Here](https://github.com/jenny1903/Minimal_Social_App/issues)

## 📈 Stats

![GitHub stars](https://img.shields.io/github/stars/jenny1903/Minimal_Social_App?style=social)
![GitHub forks](https://img.shields.io/github/forks/jenny1903/Minimal_Social_App?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/jenny1903/Minimal_Social_App?style=social)

## ⭐ Show Your Support

If you like this project, please consider:
- Giving it a ⭐️ on GitHub
- Sharing it with friends
- Contributing to the codebase
- Reporting bugs or suggesting features
- Starring the repository

---

<p align="center">
  <strong>Made with ❤️ using Flutter & Firebase</strong>
  <br>
  <sub>© 2025 Fello. All rights reserved.</sub>
</p>

---

## 🔥 Quick Start Guide

**New to the project?** Follow these steps:

1. ✅ Install Flutter SDK
2. ✅ Set up Firebase project
3. ✅ Clone repository
4. ✅ Run `flutter pub get`
5. ✅ Configure Firebase with `flutterfire configure`
6. ✅ Run `flutter run`
7. 🎉 Start building!

**Need help?** 
Check out our [Wiki](https://github.com/jenny1903/Minimal_Social_App/wiki)
or 
create an [issue](https://github.com/jenny1903/Minimal_Social_App/issues)!