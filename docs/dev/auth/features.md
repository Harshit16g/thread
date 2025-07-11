# Auth Feature In-Depth

This document provides a detailed overview of the pages and functionality within the authentication feature.

## 1. Pages & Design

### 1.1. `AuthScreen` (The Main Gateway)

-   **Design**: This is the primary landing screen for unauthenticated users. It features a full-screen, looping video background (`splashscreen.mp4`) to create a dynamic and engaging first impression.
-   **UI Components**:
    -   At the bottom, a `GlassContainer` panel is anchored, flush with the screen edges and with rounded top corners. This panel hosts the primary authentication options.
    -   The buttons (`AuthButton`) on this screen use a semi-transparent "slate blue" glass style to ensure readability over the video.

### 1.2. `LoginScreen` & `SignUpScreen`

-   **Design**: These screens provide a dedicated interface for email/password authentication. They feature a consistent, clean design with a rich gradient background using the app's primary brand colors (`#075E54` to `#128C7E`).
-   **UI Components**:
    -   A `GlassAppBar` provides a glossy, transparent navigation bar at the top.
    -   The body is wrapped in a `SingleChildScrollView` to prevent UI overflow when the keyboard appears.
    -   Inputs are handled by the reusable `CustomFormField` widget.
    -   The main action button is a glass-style `AuthButton`.
    -   The `LoginScreen` includes a "Forgot Password?" link for future implementation.

## 2. Functionality & Logic

### 2.1. User Sign-Up Flow

1.  User taps "Sign up" on the `AuthScreen`.
2.  Navigates to the `SignUpScreen`.
3.  User enters their email and password.
4.  Tapping the "Sign Up" button dispatches an `AuthSignUpRequested` event to the `AuthBloc`.
5.  The `AuthBloc` calls the `AuthRepository`, which in turn calls Supabase's `signUp` method.
    -   **Crucially**, the `emailRedirectTo` parameter is set to our app's custom deep link (`APP_REDIRECT_URI` from `.env`).
6.  Supabase sends a verification email to the user with a link containing this deep link.
7.  The UI shows a `SnackBar` informing the user to check their email and navigates back. The user is **not** logged in at this point.

### 2.2. User Login Flow (Email)

1.  User taps "Log in" on the `AuthScreen`.
2.  Navigates to the `LoginScreen`.
3.  User enters their credentials.
4.  Tapping "Log In" dispatches an `AuthLoginRequested` event.
5.  The `AuthBloc` calls the repository's `signInWithEmail` method.
6.  If successful, the Supabase client updates its state. The `AuthGate`'s stream listener detects the new session and automatically navigates to the `MainScreen`.
7.  If it fails, the `errorMessage` in the `AuthState` is updated, and a `SnackBar` is shown to the user.

### 2.3. Google Sign-In Flow (Native)

1.  User taps "Continue with Google" on the `AuthScreen`.
2.  The `AuthBloc` dispatches an `AuthSignInEvent`.
3.  The `AuthRepository` uses the `google_sign_in` package to trigger the **native Android account picker**.
4.  The user selects an account.
5.  The repository receives an `idToken` from the native Google SDK.
6.  This `idToken` is sent to Supabase's `signInWithIdToken` method for verification.
7.  If successful, `AuthGate` detects the new session and navigates to the `MainScreen`.

This comprehensive flow provides users with multiple, secure ways to access the application while maintaining a polished and consistent user experience.
