# Profile Feature Architecture Diagram

## System Overview

```mermaid
graph TB
    subgraph "Presentation Layer"
        PS[Profile Screen]
        PES[Profile Edit Screen]
        PB[Profile BLoC]
        PE[Profile Events]
        PST[Profile States]
    end
    
    subgraph "Domain Layer"
        UP[UserProfile Entity]
        PR[Profile Repository Interface]
    end
    
    subgraph "Data Layer"
        UPM[UserProfile Model]
        PRI[Profile Repository Impl]
    end
    
    subgraph "External Services"
        SB[Supabase Client]
        DB[(PostgreSQL Database)]
        ST[Storage Bucket]
    end
    
    PS -->|Displays| PST
    PS -->|Dispatches| PE
    PES -->|Dispatches| PE
    PE -->|Handled by| PB
    PB -->|Emits| PST
    PB -->|Uses| PR
    PR -.->|Implements| PRI
    PRI -->|Uses| UPM
    PRI -->|Calls| SB
    SB -->|Queries| DB
    SB -->|Uploads to| ST
    UPM -.->|Extends| UP
```

## Profile Screen Flow

```mermaid
sequenceDiagram
    participant User
    participant ProfileScreen
    participant ProfileBloc
    participant Repository
    participant Supabase
    participant Database

    User->>ProfileScreen: Navigate to Profile
    ProfileScreen->>ProfileBloc: ProfileLoadRequested(userId)
    ProfileBloc->>ProfileBloc: emit(isLoading: true)
    ProfileBloc->>Repository: getProfile(userId)
    Repository->>Supabase: query profiles table
    Supabase->>Database: SELECT * FROM profiles WHERE id = userId
    Database-->>Supabase: profile data
    Supabase-->>Repository: JSON response
    Repository-->>ProfileBloc: UserProfile entity
    ProfileBloc->>ProfileBloc: emit(profile: data, isLoading: false)
    ProfileBloc-->>ProfileScreen: ProfileState with data
    ProfileScreen->>User: Display profile information
```

## Profile Edit Flow

```mermaid
sequenceDiagram
    participant User
    participant EditScreen
    participant ProfileBloc
    participant Repository
    participant Supabase
    participant Database

    User->>EditScreen: Open Edit Screen
    EditScreen->>User: Show form with current data
    User->>EditScreen: Edit fields & Submit
    EditScreen->>EditScreen: Validate form
    EditScreen->>ProfileBloc: ProfileUpdateRequested(profile)
    ProfileBloc->>ProfileBloc: emit(isUpdating: true)
    ProfileBloc->>Repository: updateProfile(profile)
    Repository->>Supabase: update profiles table
    Supabase->>Database: UPDATE profiles SET ... WHERE id = userId
    Database-->>Supabase: success
    Supabase-->>Repository: confirmation
    Repository-->>ProfileBloc: success
    ProfileBloc->>ProfileBloc: emit(profile: updated, isUpdating: false)
    ProfileBloc-->>EditScreen: ProfileState updated
    EditScreen->>User: Show success & navigate back
```

## Authentication & Profile Creation Flow

```mermaid
sequenceDiagram
    participant User
    participant AuthScreen
    participant AuthBloc
    participant Supabase
    participant Database
    participant Trigger

    User->>AuthScreen: Sign Up / Sign In
    AuthScreen->>AuthBloc: AuthSignUpRequested
    AuthBloc->>Supabase: signUp(email, password)
    Supabase->>Database: INSERT INTO auth.users
    Database->>Trigger: on_auth_user_created
    Trigger->>Database: INSERT INTO profiles (id, email, ...)
    Database-->>Trigger: profile created
    Database-->>Supabase: user & profile created
    Supabase-->>AuthBloc: AuthResponse
    AuthBloc->>AuthGate: Auth state changed
    AuthGate->>MainScreen: Navigate to app
    MainScreen->>ProfileScreen: Load profile
```

## Clean Architecture Layers

```mermaid
graph LR
    subgraph "Presentation"
        UI[UI Widgets]
        BLOC[BLoC]
    end
    
    subgraph "Domain"
        ENT[Entities]
        REPO_INT[Repository Interface]
    end
    
    subgraph "Data"
        MODEL[Models]
        REPO_IMPL[Repository Implementation]
        DS[Data Sources]
    end
    
    UI --> BLOC
    BLOC --> REPO_INT
    REPO_INT -.-> REPO_IMPL
    REPO_IMPL --> MODEL
    REPO_IMPL --> DS
    MODEL -.-> ENT
    
    style Presentation fill:#e1f5ff
    style Domain fill:#fff3e0
    style Data fill:#f3e5f5
```

## State Management Flow

```mermaid
stateDiagram-v2
    [*] --> Initial
    Initial --> Loading: ProfileLoadRequested
    Loading --> Loaded: Success
    Loading --> Error: Failure
    Loaded --> Updating: ProfileUpdateRequested
    Updating --> Loaded: Update Success
    Updating --> Error: Update Failure
    Error --> Loading: Retry
    Loaded --> [*]: ProfileLogoutRequested
```

## Database Schema

```mermaid
erDiagram
    AUTH_USERS ||--|| PROFILES : "has one"
    PROFILES ||--o{ STORAGE_OBJECTS : "has many"
    
    AUTH_USERS {
        uuid id PK
        string email
        jsonb raw_user_meta_data
        timestamp created_at
    }
    
    PROFILES {
        uuid id PK,FK
        string email
        string full_name
        string avatar_url
        string bio
        string phone_number
        timestamp created_at
        timestamp updated_at
    }
    
    STORAGE_OBJECTS {
        uuid id PK
        string bucket_id
        string name
        string owner
    }
```

## Security Model

```mermaid
graph TB
    subgraph "Row Level Security"
        RLS1[Users can SELECT own profile]
        RLS2[Users can INSERT own profile]
        RLS3[Users can UPDATE own profile]
    end
    
    subgraph "Storage Policies"
        SP1[Public read access]
        SP2[Users can upload own avatar]
        SP3[Users can update own avatar]
        SP4[Users can delete own avatar]
    end
    
    subgraph "Application Layer"
        AUTH[Authentication Check]
        VAL[Input Validation]
        ERR[Error Handling]
    end
    
    AUTH --> RLS1
    AUTH --> RLS2
    AUTH --> RLS3
    VAL --> SP2
    VAL --> SP3
    ERR --> RLS1
```

## Component Dependencies

```mermaid
graph TB
    Main[main.dart]
    AG[AuthGate]
    MS[MainScreen]
    PS[ProfileScreen]
    PES[ProfileEditScreen]
    
    Main --> AG
    AG --> MS
    MS --> PS
    PS --> PES
    
    subgraph "Dependencies"
        AR[AuthRepository]
        PR[ProfileRepository]
        AB[AuthBloc]
        PB[ProfileBloc]
    end
    
    Main -.->|Provides| AR
    Main -.->|Provides| PR
    Main -.->|Provides| AB
    Main -.->|Provides| PB
    
    PS -->|Uses| PB
    PES -->|Uses| PB
    PB -->|Uses| PR
```

## File Structure

```
lib/features/profile/
│
├── domain/                     # Business Logic Layer
│   ├── entities/
│   │   └── user_profile.dart   # Core entity (no dependencies)
│   └── repositories/
│       └── profile_repository.dart  # Interface (depends on entities)
│
├── data/                       # Data Layer
│   ├── models/
│   │   └── user_profile_model.dart  # Model (extends entity)
│   └── repositories/
│       └── profile_repository_impl.dart  # Implementation
│
└── presentation/               # Presentation Layer
    ├── bloc/
    │   ├── profile_bloc.dart   # State manager
    │   ├── events/
    │   │   └── profile_event.dart
    │   └── states/
    │       └── profile_state.dart
    └── screens/
        ├── profile_screen.dart      # View profile
        └── profile_edit_screen.dart # Edit profile
```

## Key Design Patterns

1. **Repository Pattern**: Abstracts data sources
2. **BLoC Pattern**: Separates business logic from UI
3. **Dependency Injection**: Loose coupling via providers
4. **Factory Pattern**: Model creation from JSON
5. **Observer Pattern**: State changes notify UI
6. **Strategy Pattern**: Different authentication methods

---

These diagrams provide a visual understanding of how the profile feature is architected and how different components interact with each other.
