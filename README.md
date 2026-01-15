<p align="center">
  <img src="assets/images/Book%20Store%20Logo%201.svg" alt="Book Reader Logo" width="120"/>
</p>

<h1 align="center">📚 Book Reader</h1>

<p align="center">
  <strong>A modern, feature-rich Flutter application for reading and managing your digital book collection</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#api-integration">API Integration</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-brightgreen?style=for-the-badge" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License"/>
</p>

---

## ✨ Features

### 📖 Book Reading

- **PDF Viewer** – Read PDF books with smooth rendering using Syncfusion PDF Viewer
- **Progress Tracking** – Automatically saves your reading progress and syncs across devices
- **Search in Book** – Find specific content within your books quickly

### 📚 Library Management

- **Personal Library** – Download and manage your book collection locally
- **Custom Collections** – Organize books into personalized shelves/collections
- **Favorites** – Mark books as favorites for quick access
- **Reading History** – Track your reading progress across all books

### 🔐 User Authentication

- **Secure Login/Register** – Token-based authentication with JWT
- **Profile Management** – Update your profile and upload custom avatars
- **Onboarding Flow** – Beautiful introduction screens for new users

### 🌙 User Experience

- **Dark/Light Mode** – Toggle between themes based on your preference
- **Responsive Design** – Works seamlessly on mobile, tablet, web, and desktop
- **Beautiful Animations** – Smooth transitions and micro-interactions
- **Modern UI** – Clean, intuitive interface with Google Fonts

### 📤 Content Submission

- **Submit Books** – Users can submit their own books for review
- **Track Submissions** – View status of pending book submissions
- **Book Reviews** – Rate and review books you've read

---

## 🛠️ Tech Stack

| Category             | Technology                               |
| -------------------- | ---------------------------------------- |
| **Framework**        | Flutter 3.10+                            |
| **Language**         | Dart 3.0+                                |
| **State Management** | Provider                                 |
| **HTTP Client**      | Dio                                      |
| **PDF Viewer**       | Syncfusion Flutter PDF Viewer            |
| **Local Storage**    | SharedPreferences, SQLite                |
| **Fonts**            | Google Fonts                             |
| **Animations**       | Flutter Animate                          |
| **File Handling**    | File Picker, Image Picker, Path Provider |

---

## 🏗️ Architecture

The project follows a clean, modular architecture:

```
lib/
├── helpers/         # Constants, utilities, and navigation helpers
├── models/          # Data models (Book, User, Collection, etc.)
├── providers/       # State management with Provider pattern
│   ├── auth_provider.dart
│   ├── book_provider.dart
│   ├── category_provider.dart
│   ├── library_provider.dart
│   ├── preferences_provider.dart
│   └── progress_provider.dart
├── screens/         # UI screens
│   ├── auth/        # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── splash_screen.dart
│   │   └── onboarding_screen.dart
│   └── main/        # Main app screens
│       ├── home_screen.dart
│       ├── library_screen.dart
│       ├── favourite_screen.dart
│       ├── book_details_screen.dart
│       ├── book_reader_screen.dart
│       ├── profile_screen.dart
│       └── tabs_screen.dart
├── services/        # API service layer
│   └── api.dart
└── widgets/         # Reusable UI components
```

---

## 🔌 API Integration

The app integrates with a Laravel backend API, providing:

| Endpoint Category  | Features                           |
| ------------------ | ---------------------------------- |
| **Authentication** | Login, Register, Logout, Profile   |
| **Books**          | Browse, Search, Filter by Category |
| **Library**        | Download, Add/Remove Books         |
| **Collections**    | Create, Delete, Manage Books       |
| **Favorites**      | Add/Remove from Favorites          |
| **Progress**       | Sync Reading Progress              |
| **Reviews**        | Create, Update, Delete Reviews     |
| **Preferences**    | Theme, Font Size Settings          |

---

## 📦 Installation

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extension
- An emulator or physical device

### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/Abdooo2235/book-reader-flutter.git
   cd book-reader-flutter
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**

   Update the base URL in `lib/helpers/consts.dart`:

   ```dart
   const String baseUrl = 'https://your-api-url.com/api';
   ```

4. **Run the app**

   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome

   # For Windows
   flutter run -d windows
   ```

---

## 🎨 Theming

The app supports both light and dark themes with a warm, book-friendly color palette:

### Light Theme

- Primary Color: Warm brown tones
- Background: Cream/off-white
- Clean, readable typography

### Dark Theme

- Primary Color: Warm amber accents
- Background: Deep charcoal
- Easy on the eyes for night reading

---

## 📱 Supported Platforms

| Platform | Status       |
| -------- | ------------ |
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Web      | ✅ Supported |
| Windows  | ✅ Supported |
| macOS    | ✅ Supported |
| Linux    | ✅ Supported |

---

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Author

**Abdooo2235**

- GitHub: [@Abdooo2235](https://github.com/Abdooo2235)

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - The UI framework
- [Syncfusion](https://www.syncfusion.com/) - PDF viewer component
- [Provider](https://pub.dev/packages/provider) - State management
- Beautiful illustrations from [Storyset](https://storyset.com/)

---

<p align="center">
  Made with ❤️ and Flutter
</p>
