# Backend & Native Configuration Documentation

This document outlines the backend services and native project configurations required for the authentication feature to function correctly.

## 1. Primary Backend Service: Supabase

Supabase serves as the primary backend for authentication and data storage.

### 1.1. Environment Variables

Sensitive keys and project-specific URLs are stored in the `.env` file at the root of the project. This file is loaded at runtime and **should never be committed to version control**.

-   `SUPABASE_URL`: The unique URL for your Supabase project.
-   `SUPABASE_ANON_KEY`: The public "anonymous" key for your Supabase project.
-   `GOOGLE_WEB_CLIENT_ID`: The **Web client ID** obtained from the Google Cloud Console. This is crucial for securely verifying the Google Sign-In token on the backend.
-   `APP_REDIRECT_URI`: A custom URL scheme used for deep linking back to the app, primarily for email verification. (e.g., `io.supabase.flutterquickstart://login-callback/`)

### 1.2. Authentication Providers

The following providers are configured in the Supabase dashboard (`Authentication > Providers`):

-   **Email/Password**: Enabled by default. "Enable email confirmations" should be turned ON to ensure the verification flow works.
-   **Google**: Enabled. You must provide the **Web Client ID** and **Client Secret** from your Google Cloud Console credentials. It's also critical to add your Supabase redirect URI to the "Authorized redirect URIs" in the Google Cloud settings.

### 1.3. Database & Schema

-   **Schema Management**: All database schema changes (tables, policies, functions) should be managed via **Supabase CLI Migrations**. This keeps the schema in version control and ensures a reproducible setup.
-   **Key Tables**:
    -   `auth.users`: Managed automatically by Supabase. Contains user authentication data.
    -   `public.profiles`: A custom table that should be created to store public user data. It is linked to `auth.users` via a foreign key relationship on the `id` (UUID) column.
-   **Row Level Security (RLS)**: RLS is enabled on all public tables (e.g., `profiles`). Policies are created to ensure users can only access and modify their own data.

## 2. Native Android Configuration

### 2.1. App Name & Icon

-   **App Name**: The user-facing app name ("TabL") is set in `android/app/src/main/AndroidManifest.xml` via the `android:label` attribute.
-   **App Icon**: A proper adaptive icon is configured.
    -   **Foreground**: `ic_launcher_foreground.png` is a transparent logo placed in all `mipmap-*dpi` folders.
    -   **Background**: A solid color (`#075E54`) is defined in `android/app/src/main/res/values/colors.xml`.
    -   **XML Definition**: The adaptive icon is defined in `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`.

### 2.2. Native Splash Screen

-   To provide a seamless transition to the app's video background, a native splash screen is configured in `android/app/src/main/res/drawable/launch_background.xml`.
-   It uses the same background color as the adaptive icon and displays the foreground logo in the center.
-   This theme is applied via `android/app/src/main/res/values/styles.xml`.

### 2.3. Google Sign-In Configuration

-   **Dependencies**: The `google_sign_in` package is used to facilitate native Google Sign-In.
-   **SHA-1 Fingerprint**: To authorize the app with Google, a SHA-1 fingerprint of the signing certificate must be generated and added to the Android app credentials in the Google Cloud Console. This is a critical step for native sign-in to work.

### 2.4. Biometric Authentication

-   **Permission**: The `USE_BIOMETRIC` permission is requested in `android/app/src/main/AndroidManifest.xml`.
-   **Activity**: The `MainActivity.kt` is updated to extend `FlutterFragmentActivity`, which is a requirement for the `local_auth` plugin.

---
This documentation provides a complete picture of the backend and native setup, enabling developers to configure the environment correctly and troubleshoot issues related to native functionality.
