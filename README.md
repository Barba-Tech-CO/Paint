# PaintPro

A comprehensive Flutter application for paint contractors and professionals to manage projects, estimates, contacts, and material selection with an intuitive mobile interface.

## 🎨 Features

- **Project Management**: Create and manage painting projects with detailed estimates
- **Contact Management**: Maintain client information and project history
- **Material Selection**: Browse and select from extensive paint catalogs and materials
- **Color Selection**: Interactive color picker with brand-specific paint options
- **Estimate Generation**: Automated calculation of project costs and materials
- **Zone Management**: Define and measure different project areas
- **Photo Integration**: Capture and manage project photos
- **Authentication**: Secure user authentication and session management

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **MVVM (Model-View-ViewModel)** pattern:

### Layer Structure
```
lib/
├── features/                    # Feature-based organization
│   ├── auth/                   # Authentication feature
│   │   ├── domain/            # Business logic & entities
│   │   ├── infrastructure/    # Data sources & repositories
│   │   └── presentation/      # Views & ViewModels
│   ├── contacts/              # Contact management
│   ├── projects/              # Project management
│   ├── highlights/            # Project highlights
│   ├── create_project/        # Project creation
│   ├── zones/                 # Zone management
│   ├── overview_zones/        # Zone overview
│   ├── layout/                # App layout
│   ├── room_adjust/           # Room adjustment
│   ├── splash/                # Splash screen
│   └── home/                  # Home dashboard
├── data/                      # Global data layer
│   └── repository/           # Repository implementations
├── domain/                    # Global domain layer
│   └── repository/           # Repository interfaces
├── service/                   # External services
├── viewmodel/                 # Legacy ViewModels (being migrated)
├── view/                      # Legacy Views (being migrated)
├── config/                    # App configuration
├── model/                     # Data models
└── utils/                     # Utilities & helpers
```

### Design Patterns Used
- **Repository Pattern**: Abstracts data access logic
- **Dependency Injection**: Uses GetIt for IoC container
- **Provider Pattern**: State management with ChangeNotifier
- **Result Pattern**: Error handling with custom Result type
- **Factory Pattern**: Object creation through DI container

## 🔧 Technical Stack

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management solution
- **GetIt**: Dependency injection container
- **GoRouter**: Declarative routing solution
- **HTTP**: REST API communication
- **Logger**: Structured logging system

## 📱 Key Screens

1. **Splash Screen**: App initialization and authentication check
2. **Authentication**: OAuth-based login system
3. **Home Dashboard**: Project overview and quick actions
4. **Projects**: Project listing and management
5. **Contact Management**: Client information and history
6. **Material Selection**: Browse and select painting materials
7. **Color Selection**: Interactive color picker with brand catalogs
8. **Zone Management**: Define and measure project areas
9. **Estimate Generation**: Automated cost calculations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- iOS development: Xcode 14+
- Android development: Android Studio

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Paint
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Development Setup

1. **Dependency Injection**: All dependencies are configured in `lib/config/dependency_injection.dart`
2. **Routing**: App navigation is defined in `lib/config/routes.dart`
3. **Theming**: App colors and themes in `lib/config/`

## 📂 Project Structure Details

### Repository Pattern Implementation
```dart
// Domain Layer
abstract class IMaterialRepository {
  Future<Result<List<MaterialModel>>> getAllMaterials();
}

// Data Layer
class MaterialRepository implements IMaterialRepository {
  final MaterialService _service;
  // Implementation...
}

// Dependency Injection
getIt.registerLazySingleton<IMaterialRepository>(
  () => MaterialRepository(materialService: getIt<MaterialService>()),
);
```

### MVVM Implementation
```dart
class MaterialListViewModel extends ChangeNotifier {
  final IMaterialRepository _repository;
  
  MaterialListViewModel(this._repository);
  
  Future<void> loadMaterials() async {
    final result = await _repository.getAllMaterials();
    // Handle result and notify listeners
  }
}
```

## 🔄 Migration Status

The project is currently undergoing migration from legacy structure to feature-based clean architecture:

### ✅ Completed Migrations
- Splash feature → `lib/features/splash/`
- Home feature → `lib/features/home/`
- Projects feature → `lib/features/projects/`
- Highlights feature → `lib/features/highlights/`
- Create Project feature → `lib/features/create_project/`
- Zones feature → `lib/features/zones/`
- Overview Zones feature → `lib/features/overview_zones/`
- Layout feature → `lib/features/layout/`
- Room Adjust feature → `lib/features/room_adjust/`

### 📦 Repository Layer
- ✅ AuthRepository
- ✅ ContactRepository
- ✅ EstimateRepository
- ✅ MaterialRepository
- ✅ PaintCatalogRepository

## 📋 Development Guidelines

1. **Feature Development**: Create new features under `lib/features/`
2. **Repository Pattern**: Always use repository interfaces for data access
3. **Dependency Injection**: Register all dependencies in `dependency_injection.dart`
4. **State Management**: Use ChangeNotifier-based ViewModels
5. **Error Handling**: Use the Result pattern for error management
6. **Logging**: Use LoggerService for structured logging

## 🤝 Contributing

1. Follow the established architecture patterns
2. Create feature-based modules under `lib/features/`
3. Implement proper repository interfaces
4. Use dependency injection for all dependencies
5. Write comprehensive tests for new features

## 📄 License

This project is proprietary software developed for PaintPro.
