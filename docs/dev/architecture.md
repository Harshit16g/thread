# TabL: Detailed Developer Architecture
*Version 1.1, January 2025*

---

## 1. Introduction
This document provides a detailed, developer-focused breakdown of the TabL application architecture. It is the primary technical blueprint for building, maintaining, and extending the application. All development should adhere to the principles and patterns outlined here.

This document is a deep dive into the **[Architectural Foundation & Integration Strategy](../Architectural_Foundation_and_Integration_Strategy.md)**.

## 2. Core Architectural Principles
-   **Clean Architecture**: We enforce a strict separation of concerns between the UI (Presentation), business logic (BLoC), and data handling (Data/Domain).
-   **Feature-First Structure**: The codebase is organized by feature, not by layer. Each feature is a self-contained vertical slice of the application, which makes the code easier to navigate and maintain.
-   **Supabase-First Backend**: We do not maintain a custom backend server. All backend logic is handled through the Supabase platform, using its auto-generated APIs and serverless PostgreSQL Functions.
-   **Dependency Injection**: We use a central service locator (`get_it`) to manage dependencies, making our components decoupled and highly testable.

## 3. System Architecture Diagram
This diagram illustrates the flow of data and control between the various layers of the application and the backend services.

```mermaid
graph TB
    subgraph "Presentation Layer (UI)"
        A[Screens & Widgets] --> B[BLoCs]
    end

    subgraph "Domain & Data Layers (Flutter)"
        B --> C{Repositories<br/>(The App's Brain)}
        C --> D[Data Sources<br/>Supabase, Redis, SecureStorage]
    end
    
    subgraph "Core Infrastructure (Backend)"
        S[Supabase Platform<br/>Auth, Functions, Realtime]
        R[Upstash Redis<br/>Caching & Pub/Sub]
        N[Neon DB<br/>PostgreSQL]
        Se[Sentry<br/>Error Monitoring]
    end

    subgraph "External APIs"
        GM[Google Maps]
        RE[Resend/Brevo]
    end

    %% Data Flow
    D -- gRPC/REST --> S
    D -- TCP --> R
    S -- Manages --> N
    
    %% External API Flow
    D -- API Call --> GM
    S -- API Call --> RE

    %% Global Integration
    FlutterApp[Flutter App Instance] -- SDK --> Se

    %% Styling
    classDef presentationLayer fill:#e3f2fd,stroke:#b3e5fc,color:#0d47a1
    classDef dataLayer fill:#e8f5e8,stroke:#c8e6c9,color:#1b5e20
    classDef coreLayer fill:#fce4ec,stroke:#f8bbd0,color:#880e4f
    classDef externalLayer fill:#fff3e0,stroke:#ffe0b2,color:#e65100
    
    class A,B presentationLayer
    class C,D dataLayer
    class S,R,N,Se coreLayer
    class GM,RE externalLayer
```

## 4. Detailed Flutter Project Structure

```
lib/
├── core/
│   ├── config/         # AppConfig for environment variables
│   ├── di/             # Dependency Injection setup (GetIt)
│   ├── errors/         # Custom Failure and Exception classes
│   ├── services/       # Abstract services (e.g., NotificationService)
│   └── theme/          # App-wide theme, colors, text styles
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/  # Remote (Supabase) and Local data sources
│       │   └── repositories/ # Concrete implementation of the repository
│       ├── domain/
│       │   ├── entities/     # Plain Dart objects for the feature
│       │   └── repositories/ # Abstract repository interface
│       └── presentation/
│           ├── bloc/         # BLoC, Events, and States
│           ├── screens/      # The UI screens for the feature
│           └── widgets/      # Feature-specific widgets
│
├── shared/
│   └── widgets/          # Reusable widgets shared across multiple features
│
└── main.dart             # App entry point, DI setup, initialization
```

## 5. Layer Responsibilities

### 5.1. Presentation Layer
-   **Screens**: Composes widgets to build a full-screen user interface. They are responsible for providing the necessary BLoCs to their widget tree.
-   **Widgets**: Small, reusable UI components. Widgets should be "dumb" and only react to the state they are given. They dispatch events to the BLoC in response to user interaction.
-   **BLoC (Business Logic Component)**:
    -   Receives events from the UI.
    -   Communicates with one or more repositories to fulfill the request.
    -   Contains all the business logic for a feature (e.g., validation, decision-making).
    -   Emits new states to the UI.
    -   **A BLoC should NEVER directly access a data source.** It must always go through a repository.

### 5.2. Domain Layer
-   **Repositories (Abstract)**: Defines the "contract" for a data source. It exposes a clean API for the BLoC to use. For example, `abstract class AuthRepository { Future<void> login(String email); }`. This is the key to decoupling your business logic from your data sources.
-   **Entities**: Plain Dart objects that represent the core data structures of your app (e.g., `User`, `Listing`). They contain no business logic.

### 5.3. Data Layer
-   **Repositories (Implementation)**: The concrete implementation of the repository contract. This is where the actual calls to Supabase, Redis, or other services happen.
-   **Data Sources**: A class responsible for communicating with a single source of data (e.g., `AuthSupabaseDataSource`, `AuthLocalDataSource`). A repository can coordinate multiple data sources (e.g., fetching from a cache first, then from the network).
-   **Models**: Data transfer objects that are specific to a data source. For example, a `UserModel` might have `fromJson` and `toJson` methods to handle data from the Supabase API. These models are converted to `Entities` before being sent to the domain/presentation layers.

This architecture ensures that as the TabL application grows, it remains organized, testable, and easy for new developers to understand.
