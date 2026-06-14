# 🏠 Smart Space - Frontend

> An AI-powered mobile application for measuring spaces and getting intelligent product recommendations using computer vision

## 📱 Overview

Smart Space is a Flutter-based mobile application that leverages camera technology and AI to help users measure available spaces. Simply capture an image of your room, and our AI will:
- Analyze dimensions and spatial context
- Generate accurate measurements
- Provide intelligent product recommendations tailored to your space
- Store measurement history for future reference

## ✨ Features

- 📸 **Real-time Camera Capture** - High-quality image capture with preview
- 🤖 **AI Space Analysis** - Advanced computer vision for dimension detection
- 📐 **Automated Measurements** - Get accurate space dimensions instantly
- 🛋️ **Smart Recommendations** - AI-powered product suggestions based on space analysis
- 💾 **History Management** - Keep track of all your measurements
- 🔔 **Push Notifications** - Stay updated with Firebase Cloud Messaging
- 📊 **Charts & Analytics** - Visualize your space metrics
- 🎥 **Video Support** - Record space walkthroughs
- 🔐 **Secure Storage** - Local data persistence with SharedPreferences

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Backend Communication**: HTTP
- **Camera & Media**: 
  - `camera` - Live camera access
  - `image_picker` - Gallery and camera image selection
  - `video_player` - Video playback
  - `video_thumbnail` - Video preview generation
- **Notifications**: Firebase Cloud Messaging + Local Notifications
- **Data Visualization**: FL Chart
- **Storage**: SharedPreferences, Path Provider
- **Internationalization**: Intl
- **Permissions**: Permission Handler

## 📋 Prerequisites

- Flutter SDK >= 3.3.4
- Dart SDK >= 3.3.4
- Android SDK (for Android builds)
- Xcode (for iOS builds)
- Firebase project setup

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/Karthiksenthilkumar1/Smart-Space.git
cd Smart-Space
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add your Android and iOS apps to the project
3. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

### 4. Setup Environment Variables
Create a `.env` file in the project root (if needed for API endpoints)

### 5. Run the App
```bash
# Development
flutter run

# Release build
flutter run --release
```

## 🏗️ Project Structure

```
smart_space/
├── lib/
│   ├── main.dart              # Entry point
│   ├── screens/               # UI screens
│   ├── models/                # Data models
│   ├── services/              # API & Firebase services
│   ├── providers/             # State management
│   ├── widgets/               # Reusable widgets
│   └── utils/                 # Helper functions
├── android/                   # Android native code
├── ios/                       # iOS native code
├── pubspec.yaml              # Dependencies
└── README.md
```

## 🔗 API Integration

The app connects to the Smart Space Backend API for:
- Space analysis and AI recommendations
- User authentication
- Image processing
- Measurement history storage

### Backend Repository
[smart_space_backend](https://github.com/Karthiksenthilkumar1/smart_space_backend)

## 📱 Supported Platforms

- ✅ Android (API 24+)
- ✅ iOS (12.0+)

## 🔐 Permissions Required

- 📷 Camera access
- 📸 Photo library access
- 📍 Location (optional)
- 🔔 Notification permission

## 📝 Usage

1. **Launch the App** - Open Smart Space on your mobile device
2. **Capture Space** - Take a photo or video of the room you want to measure
3. **AI Analysis** - Wait for the AI to analyze dimensions and context
4. **View Results** - Check measurements and get product recommendations
5. **Save History** - All measurements are automatically saved locally

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🐛 Troubleshooting

### Camera Permission Issues
- Ensure permissions are granted in system settings
- Check `permission_handler` configuration in `android/` and `ios/` directories

### Firebase Connection Issues
- Verify Firebase configuration files are in correct locations
- Check internet connectivity
- Ensure Firebase project is properly configured

### Build Issues
- Run `flutter clean` to clear build cache
- Update dependencies: `flutter pub upgrade`
- Check Flutter version: `flutter --version`

## 📦 Build & Release

### Android Release Build
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

### iOS Release Build
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Support & Contact

For issues, questions, or suggestions, please open an issue on the GitHub repository.

## 🙏 Acknowledgments

- Flutter community for amazing packages
- Firebase for cloud services
- Google Generative AI for AI capabilities
- All contributors and testers

---

**Made with ❤️ by Smart Space Team**
