# ARES Apparel Store - 2nd Semester Flutter App

A fully functional Flutter e-commerce application demonstrating advanced concepts and best practices for 2nd-semester development. This app showcases comprehensive state management, responsive design, device capabilities, and modern UI patterns.

## 🚀 Features

### ✅ State Management (Provider Pattern)
- **AuthProvider**: User authentication and profile management with persistent login
- **ThemeProvider**: Light/dark mode switching with system theme detection
- **CartProvider**: Shopping cart operations with real-time updates
- **ProductProvider**: Master/detail product management with filtering and search
- **NavigationProvider**: Bottom navigation state management

### ✅ Master/Detail Navigation
- **ProductListScreen**: Comprehensive product catalog with filtering, sorting, and search
- **ProductDetailScreen**: Rich product details with image carousel, specifications, and reviews
- **Smooth animations** between master and detail views
- **Hero animations** for seamless transitions

### ✅ Enhanced Theming & Responsiveness  
- **Material 3 Design System** with consistent design tokens
- **Automatic light/dark mode** based on system settings
- **Responsive layouts** adapting to different screen sizes and orientations
- **Custom color schemes** and typography for brand consistency

### ✅ Comprehensive Forms

  - Text inputs with validation
  - Number inputs with formatting
  - Dropdown selections
  - Date and time pickers
  - Switches and checkboxes
  - Multi-select chips
  - Slider controls
  - Rich text areas

### ✅ Animations & Micro-interactions
- **Smooth page transitions** with custom animation controllers
- **Hover effects** on product cards (desktop/web support)
- **Loading states** with animated indicators
- **Button press feedback** with scale animations
- **List item animations** with staggered entrance effects
- **Floating action button** animations

### ✅ Device Capabilities
- **Network connectivity detection** with offline messaging
- **Geolocation services** for location-based features
- **Camera integration** for image capture
- **Sensor access** (accelerometer, gyroscope, battery)
- **Haptic feedback** for enhanced user experience

### ✅ Architecture & Code Quality
- **Clean architecture** with separated concerns:
  - `/screens` - UI screens and pages
  - `/widgets` - Reusable UI components
  - `/providers` - State management classes
  - `/models` - Data models and entities
  - `/utils` - Helper services and utilities
  - `/constants` - App-wide constants and themes
  - `/data` - Hardcoded data and local storage
- **Comprehensive comments** explaining functionality
- **Error handling** throughout the application
- **Type safety** with proper Dart typing

## 🛠 Technical Stack

- **Flutter SDK**: ^3.7.2
- **Dart**: Latest stable version
- **State Management**: Provider ^6.1.2
- **Local Storage**: SharedPreferences ^2.2.3
- **Device Features**: 
  - Geolocator ^12.0.0
  - Image Picker ^1.1.2
  - Sensors Plus ^6.0.1
  - Battery Plus ^6.0.2
  - Connectivity Plus ^6.0.5
- **UI Components**: Material 3 Design System
- **Animations**: Built-in Flutter AnimationController

## 📱 Screens Overview

1. **SplashScreen**: App initialization with loading animation
2. **HomeScreen**: Featured products and quick navigation
3. **ProductListScreen**: Master list with filtering and search
4. **ProductDetailScreen**: Detailed product view with all information
5. **CartScreen**: Shopping cart management
6. **CategoryScreen**: Product categories organization
7. **ProfileScreen**: User profile and settings
8. **DeviceCapabilitiesDemo**: Sensor and device feature testing

## 🎯 Learning Objectives Demonstrated

### State Management
- ✅ Provider pattern implementation
- ✅ Multiple providers working together
- ✅ State persistence with SharedPreferences
- ✅ Reactive UI updates

### Theme & Responsiveness
- ✅ Material 3 theming system
- ✅ Light/dark mode switching
- ✅ Responsive design patterns
- ✅ System theme integration

### Master/Detail Pattern
- ✅ List-detail navigation
- ✅ State preservation between screens
- ✅ Hero animations for smooth transitions
- ✅ Search and filtering capabilities

### Device Integration
- ✅ Network connectivity monitoring
- ✅ Location services
- ✅ Camera functionality
- ✅ Sensor data access
- ✅ Platform-specific features

### Form Handling
- ✅ Multiple input types
- ✅ Validation logic
- ✅ Form state management
- ✅ User experience best practices

### Animations
- ✅ Page transitions
- ✅ Micro-interactions
- ✅ Loading states
- ✅ Gesture feedback

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd Flutter-Ares-apparel-store
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS and Xcode)
flutter build ios --release

# Web
flutter build web
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with provider setup
├── constants/               
│   ├── app_theme.dart       # Material 3 theme configuration
│   ├── app_colors.dart      # Color constants
│   └── text_styles.dart     # Typography definitions
├── providers/               
│   ├── auth_provider.dart   # Authentication state
│   ├── theme_provider.dart  # Theme management
│   ├── cart_provider.dart   # Shopping cart state
│   ├── product_provider.dart # Product catalog state
│   └── navigation_provider.dart # Navigation state
├── screens/                 
│   ├── splash_screen.dart   # Initial loading screen
│   ├── main_navigation.dart # Bottom navigation wrapper
│   ├── home_screen.dart     # Home dashboard
│   ├── product_list_screen.dart # Master product list
│   ├── product_detail_screen.dart # Detail product view
│   ├── cart_screen.dart     # Shopping cart
│   └── profile_screen.dart  # User profile
├── widgets/                 
│   ├── product_card.dart    # Enhanced product card with animations
│   ├── network_status_widget.dart # Offline detection
│   └── [other reusable widgets]
├── models/                  
│   ├── product.dart         # Product data model
│   ├── user.dart           # User data model
│   └── category.dart       # Category data model
├── data/                   
│   ├── product_data.dart   # Hardcoded product catalog
│   └── category_data.dart  # Category information
└── utils/                  
    ├── network_service.dart # Network connectivity service
    ├── geolocation_service.dart # Location services
    └── [other utility services]
```

## 🎨 Design Patterns Used

1. **Provider Pattern**: For state management across the app
2. **Singleton Pattern**: For service classes (NetworkService, etc.)
3. **Factory Pattern**: For model object creation from JSON
4. **Observer Pattern**: Through Provider's ChangeNotifier
5. **Builder Pattern**: For complex UI construction
6. **Strategy Pattern**: For different theme configurations

## 🔧 Configuration

### App Themes
The app supports both light and dark themes with Material 3 design:
- Themes automatically follow system settings
- Manual theme switching available in settings
- Consistent color schemes and typography

### State Persistence
User preferences and authentication state persist across app restarts:
- Login status and user data
- Theme preferences
- Navigation history
- Cart contents (optional)

### Network Handling
Robust network connectivity management:
- Real-time connectivity monitoring
- Offline state detection
- Graceful degradation of features
- User notifications for connection issues

## 📊 Performance Considerations

- **Lazy loading** of product images
- **Efficient state updates** to minimize rebuilds
- **Image caching** for better performance
- **Responsive widgets** for different screen sizes
- **Memory management** in animations and providers

## 🧪 Testing

The app includes comprehensive error handling and input validation:
- Form field validation with user-friendly messages
- Network error handling with retry mechanisms
- State consistency checks
- Image loading fallbacks

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (responsive design)
- ✅ Desktop (Windows, macOS, Linux with responsive layout)

## 🤝 Contributing

This is an educational project demonstrating Flutter concepts for 2nd-semester development. Key learning areas include:

1. **State Management Mastery**
2. **Advanced UI Patterns**
3. **Device Integration**
4. **Performance Optimization**
5. **Code Organization**

## 📝 License

This project is created for educational purposes as part of a 2nd-semester Flutter development course.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Material Design team for the design system
- Provider package maintainers for state management solution
- Community contributors for various plugins used

---

**Built with ❤️ using Flutter for 2nd-semester development learning**-sem2

