# Fello 🌟

A minimal and elegant social media mobile application built with Flutter. Connect, share, and engage with your circle in a beautifully crafted interface that prioritizes simplicity and user experience.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)

## 📖 About

Fello is a modern, minimalist social media application designed for meaningful connections. Built with Flutter, it offers a seamless cross-platform experience with beautiful animations and an intuitive interface inspired by contemporary iOS design patterns.

## ✨ Features

### Core Functionality
- 🔐 **Secure Authentication** - User registration and login with JWT
- 📱 **Social Feed** - Share posts, images, and moments
- 💬 **Real-time Messaging** - Instant chat with friends
- 👤 **User Profiles** - Customizable profiles with avatars and bios
- ❤️ **Engagement** - Like, comment, and interact with posts
- 🔔 **Notifications** - Stay updated with real-time alerts
- 🌓 **Theme Support** - Beautiful light and dark modes
- 🎨 **Smooth Animations** - Fluid transitions and micro-interactions

### UI/UX Highlights
- Clean, minimal interface design
- Shimmer loading effects
- Pull-to-refresh functionality
- Lottie animations
- Blur effects and glassmorphism
- Responsive layouts for all screen sizes

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your system:

- **Flutter SDK**: 3.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: 3.0 or higher (comes with Flutter)
- **Android Studio** or **Xcode** for mobile development
- **Git** for version control
- A code editor (**VS Code**, **Android Studio**, or **IntelliJ IDEA**)

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

3. **Check Flutter setup**
```bash
flutter doctor
```

4. **Run the app**

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
├── core/
│   ├── theme/              # App themes, colors, and text styles
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── constants/          # App-wide constants
│   │   └── app_constants.dart
│   └── utils/              # Helper functions and utilities
│       └── helpers.dart
├── features/
│   ├── splash/             # Splash screen
│   │   └── splash_screen.dart
│   ├── auth/               # Authentication (login/register)
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   ├── home/               # Home feed and posts
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── profile/            # User profiles
│   │   ├── screens/
│   │   └── widgets/
│   ├── chat/               # Messaging feature
│   │   ├── screens/
│   │   └── models/
│   └── notifications/      # Push notifications
│       └── screens/
└── shared/
    ├── widgets/            # Reusable UI components
    │   ├── custom_button.dart
    │   ├── loading_widget.dart
    │   └── post_card.dart
    ├── models/             # Data models
    │   ├── user_model.dart
    │   └── post_model.dart
    └── services/           # API services and network
        ├── api_service.dart
        └── storage_service.dart
```

## 📦 Key Dependencies

### UI/UX & Animations
```yaml
flutter_animate: ^4.5.0              # Smooth animations
shimmer: ^3.0.0                      # Skeleton loading
flutter_spinkit: ^5.2.0              # Loading indicators
loading_animation_widget: ^1.2.0     # Custom loaders
lottie: ^3.1.2                       # Complex animations
blurrycontainer: ^2.1.0              # Blur effects
```

### Performance & Caching
```yaml
cached_network_image: ^3.3.1         # Image caching
pull_to_refresh: ^2.0.0              # Pull-to-refresh
```

### State Management & Navigation
*(Recommended additions)*
```yaml
flutter_riverpod: ^2.4.9             # State management
go_router: ^12.1.3                   # Navigation
```

### Backend & Storage
*(Recommended additions)*
```yaml
dio: ^5.4.0                          # HTTP client
hive_flutter: ^1.1.0                 # Local database
firebase_core: ^2.24.2               # Firebase integration
```

See complete list in [pubspec.yaml](pubspec.yaml)

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#0066FF`
- **Light Blue**: `#00AAFF`
- **Dark Background**: `#0A0A1A` → `#1A1A3A`
- **Text Primary**: `#FFFFFF`
- **Text Secondary**: `#A0A0A0`

### Typography
- **Font Family**: Inter, SF Pro Display
- **Heading**: 24-32px, Weight 600-700
- **Body**: 14-16px, Weight 400
- **Caption**: 12px, Weight 300

### Animation Principles
- Smooth transitions (200-300ms)
- Spring animations for interactive elements
- Subtle micro-interactions
- Shimmer effects for loading states

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | Riverpod (recommended) |
| **Backend** | REST API / Firebase |
| **Local Storage** | Hive / SharedPreferences |
| **Authentication** | JWT / Firebase Auth |
| **Animations** | flutter_animate, Lottie |

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
- Write meaningful commit messages
- Add comments for complex logic
- Test your changes thoroughly
- Update documentation if needed

## 🐛 Bug Reports & Feature Requests

Found a bug or have a feature idea? Please create an issue:

1. Go to the [Issues](https://github.com/jenny1903/Minimal_Social_App/issues) tab
2. Click "New Issue"
3. Choose the appropriate template
4. Fill in the details
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
- The open-source community for incredible packages
- Design inspiration from modern social media platforms
- All contributors who help improve Fello

## 📞 Support & Community

Need help or want to discuss ideas?

- 📧 Email: jennyberry1330@gmail.com

## ⭐ Show Your Support

If you like this project, please consider:
- Giving it a ⭐️ on GitHub
- Sharing it with friends
- Contributing to the codebase
- Reporting bugs or suggesting features

---

<p align="center">
  <strong>Made with ❤️ using Flutter</strong>
  <br>
  <sub>© 2025 Fello. All rights reserved.</sub>
</p>