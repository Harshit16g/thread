# Application Architecture

This document outlines the high-level architecture of the TabL application, designed for scalability, maintainability, and a clear separation of concerns.

## 1. Guiding Principles

-   **Feature-First**: The application is organized by features (e.g., `auth`, `marketplace`, `ridesharing`). Each feature is a self-contained module, minimizing dependencies between features.
-   **Clean Architecture**: We adhere to the principles of Clean Architecture, separating our code into distinct layers:
    -   **Domain**: Contains the core business logic, entities, and repository interfaces. This layer is the most abstract and has no dependencies on other layers.
    -   **Data**: Implements the repository interfaces defined in the domain layer. It is responsible for all data retrieval and storage, whether from a remote API (like Supabase), a local database, or secure storage.
    -   **Presentation**: Responsible for the UI and state management. This layer depends on the domain layer but is completely unaware of the data layer.
-   **Dependency Injection (DI)**: We use the `flutter_bloc` package's `RepositoryProvider` and `BlocProvider` to inject dependencies (like repositories and BLoCs) into the widget tree. This decouples our widgets from the concrete implementations of their dependencies, making them easier to test and reuse.

## 2. Directory Structure Overview

```plaintext
lib/
├── features/         # Main application features (e.g., auth, marketplace)
│   └── <feature_name>/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── core/             # Cross-cutting concerns and global services
│   ├── services/     # Singleton services (e.g., LocalAuthService)
│   └── theme/        # App-wide theming constants
│
├── shared/           # Reusable widgets shared across multiple features
│   └── widgets/
│
├── auth_gate.dart    # Root widget for handling auth state
└── main.dart         # App entry point and DI setup
```

## 3. State Management Strategy

-   **BLoC (Business Logic Component)** is our primary state management solution.
-   **Feature-Scoped BLoCs**: Each feature has its own set of BLoCs that manage its specific state. This prevents a single, monolithic state object and ensures that state is only loaded when the relevant feature is active.
-   **Events & States**: BLoCs receive events from the UI and emit states in response. This creates a unidirectional data flow that is predictable and easy to debug.

## 4. Navigation

-   **`AuthGate`**: This widget is the master controller for navigation at the highest level. It listens to the Supabase authentication stream (`onAuthStateChange`) and decides whether to show the `AuthScreen` or the `MainScreen` (the main app with the bottom navigation bar).
-   **Within Features**: Navigation between screens within a feature (e.g., from `AuthScreen` to `LoginScreen`) is handled using standard `MaterialPageRoute`.

This architecture ensures that as the TabL application grows, it remains organized, testable, and easy for new developers to understand.
