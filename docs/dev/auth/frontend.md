# Frontend Authentication Documentation

This document outlines the frontend implementation of the authentication feature in the TabL application, following a scalable, feature-first architecture.

## 1. Directory Structure

The `auth` feature is self-contained within `lib/features/auth/` and follows standard clean architecture principles:

-   **/data**: Contains the implementation of repositories.
    -   `repositories/auth_repository_impl.dart`: Concrete implementation of the `AuthRepository`. It handles the direct communication with Supabase and Google Sign-In services.
-   **/domain**: Contains the abstract business logic and entities.
    -   `repositories/auth_repository.dart`: Defines the contract (interface) for authentication-related actions like `signInWithGoogle`, `signUp`, and `signOut`.
-   **/presentation**: Contains the UI and state management logic.
    -   `bloc/`: Holds all BLoC-related classes.
        -   `auth_bloc.dart`: The core of the state management, handling events and emitting states.
        -   `events/auth_event.dart`: Defines all user-triggered events (e.g., `AuthLoginRequested`).
        -   `states/auth_state.dart`: Defines the possible states of the auth UI (e.g., `loading`, `error`).
    -   `screens/`: Contains the main UI widgets for the feature.
        -   `auth_screen.dart`: The main landing screen with the video background and login/signup options.
        -   `login_screen.dart`: The screen for users to sign in with email and password.
        -   `signup_screen.dart`: The screen for users to create a new account.
    -   `widgets/`: Contains feature-specific reusable widgets.
        -   `auth_options_panel.dart`: The modular, glass-style bottom panel on the `AuthScreen`.

## 2. Core Components & Logic

### State Management: `AuthBloc`

-   **Purpose**: Manages the state for the entire authentication flow. It receives events from the UI, interacts with the `AuthRepository`, and emits new states that the UI rebuilds against.
-   **Events**: `AuthLoginRequested`, `AuthSignUpRequested`, `AuthSignInEvent(google)`.
-   **States**: `AuthState` which contains properties like `isLoading`, `errorMessage`, and `signInType` to allow the UI to react granularly.

### UI Components

-   **`AuthScreen`**: A stateful widget that manages a looping video background. It displays the `AuthOptionsPanel`.
-   **`LoginScreen` / `SignUpScreen`**: Stateful widgets that use `TextEditingController`s for form input. They use the `GlassAppBar` for a consistent look and the `AuthButton` for actions.
-   **`AuthGate` (`lib/auth_gate.dart`)**: The root-level widget that directs users to the correct screen based on their authentication state. It listens to `Supabase.instance.client.auth.onAuthStateChange` and shows either the `AuthScreen` or the `MainScreen` (the app's home).

### Shared/Reusable Components (`lib/shared/widgets/`)

-   **`AuthButton`**: A powerful, stateful button that provides visual feedback on press. It supports different styles (`solid` for the prominent Google button, `glass` for others) and includes a drop shadow for a "lift" effect.
-   **`GlassContainer`**: The base for the "glassmorphism" effect. It uses a `BackdropFilter` to blur the content behind it and can be customized with different border radiuses.
-   **`GlassAppBar`**: A reusable, transparent app bar built upon `GlassContainer` for a consistent look in the login and sign-up flows.
-   **`CustomFormField`**: A standardized `TextFormField` used across the login and sign-up forms.

## 3. Authentication Flow

1.  **App Start**: The app's `home` is `AuthGate`.
2.  **State Check**: `AuthGate` listens to the Supabase auth stream.
    -   If **logged in**, it shows `MainScreen`.
    -   If **not logged in**, it shows `AuthScreen`.
3.  **User Action**: On the `AuthScreen`, the user can choose to sign in with Google or navigate to the `LoginScreen` or `SignUpScreen`.
4.  **BLoC Handling**:
    -   Pressing a button on any auth screen dispatches an event to the `AuthBloc`.
    -   The `AuthBloc` sets its state to `isLoading: true` and calls the appropriate method on the `AuthRepository`.
    -   The `AuthRepository` communicates with the Supabase backend.
    -   Upon completion, the BLoC emits a new state (`isLoading: false`, with an optional `errorMessage`).
5.  **UI Update**: The UI widgets listen to the BLoC state changes and rebuild accordingly (e.g., showing a loading indicator, displaying an error message, or navigating).
6.  **Successful Login**: A successful login/sign-up triggers a change in the Supabase auth stream, which is picked up by `AuthGate`, automatically navigating the user to the `MainScreen`.

---
This documentation provides a solid foundation for any developer to understand, maintain, and extend the authentication feature.
