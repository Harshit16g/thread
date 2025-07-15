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
-   `CLERK_PUBLISHABLE_KEY`: The publishable key for your Clerk project, used for integrating additional social providers.

### 1.2. Authentication Providers

Navigate to the "Authentication" -> "Providers" section in your Supabase dashboard.

-   **Email**: Ensure this is enabled. "Enable email confirmations" should be **ON**.
-   **Google**:
    -   Enable the Google provider.
    -   You will need a **Web Client ID** and **Client Secret** from the Google Cloud Console.
    -   Under "Authorized redirect URIs" in your Google Cloud OAuth settings, you **must** add the callback URL from your Supabase dashboard. It will look like: `https://<YOUR-PROJECT-REF>.supabase.co/auth/v1/callback`

### 1.3. URL Configuration

Navigate to "Authentication" -> "URL Configuration" in your Supabase dashboard.

-   **Site URL**: Set this to your app's deep link scheme. For this project, we use: `io.supabase.flutterquickstart://login-callback/`
-   **Redirect URLs**: Add the same deep link URL to the allowed redirect URLs.

## 2. Native Android Configuration

### 2.1. App Name & Icon

-   **App Name**: The user-facing app name ("TabL") is set in `android/app/src/main/AndroidManifest.xml` via the `android:label` attribute.
-   **App Icon**: A proper adaptive icon is configured.
    -   **Foreground**: `ic_launcher_foreground.png` is a transparent logo placed in all `mipmap-*dpi` folders.
    -   **Background**: A solid color (`#075E54`) is defined in `android/app/src/main/res/values/colors.xml`.
    -   **XML Definition**: The adaptive icon is defined in `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`.

### 2.2. Google Sign-In & Firebase Setup

-   **Package Name**: The application ID is set to `com.oeeez.oeon` in `android/app/build.gradle.kts`. This **must** match the package name in your Firebase project.
-   **`google-services.json`**: To enable native Google Sign-In and other Firebase services, you must download the `google-services.json` file from your Firebase project console and place it in the `android/app/` directory.
-   **Gradle Plugins**: The `com.google.gms.google-services` plugin is applied in both the project-level and app-level `build.gradle.kts` files to process the configuration file.

### 2.3. Biometric Authentication

-   **Permission**: The `USE_BIOMETRIC` permission is requested in `android/app/src/main/AndroidManifest.xml`.
-   **Activity**: The `MainActivity.kt` is updated to extend `FlutterFragmentActivity`, which is a requirement for the `local_auth` plugin.

---
This documentation provides a complete picture of the backend and native setup, enabling developers to configure the environment correctly and troubleshoot issues related to native functionality.
