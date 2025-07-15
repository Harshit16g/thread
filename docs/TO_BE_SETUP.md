# TabL Project Setup Guide

This document contains all necessary steps and information required to configure the external services (Supabase, Google Cloud, Clerk, etc.) needed for the application to function correctly.

## 1. Supabase Configuration

### 1.1 Project Credentials

These values must be present in your root `.env` file.

-   `SUPABASE_URL`: The URL of your Supabase project.
-   `SUPABASE_ANON_KEY`: The public `anon` key for your Supabase project.

### 1.2 Authentication Providers

Navigate to the "Authentication" -> "Providers" section in your Supabase dashboard.

-   **Email**: Ensure this is enabled. "Enable email confirmations" should be **ON**.
-   **Google**:
    -   Enable the Google provider.
    -   You will need a **Web Client ID** and **Client Secret** from the Google Cloud Console.
    -   Under "Authorized redirect URIs" in your Google Cloud OAuth settings, you **must** add the callback URL from your Supabase dashboard. It will look like: `https://<YOUR-PROJECT-REF>.supabase.co/auth/v1/callback`

### 1.3 URL Configuration

Navigate to "Authentication" -> "URL Configuration" in your Supabase dashboard.

-   **Site URL**: Set this to your app's deep link scheme. For this project, we use: `io.supabase.flutterquickstart://login-callback/`
-   **Redirect URLs**: Add the same deep link URL to the allowed redirect URLs.

## 2. Google Cloud Platform Configuration

### 2.1 Firebase Project

-   A Firebase project is required to generate the `google-services.json` file.
-   Create a Firebase project and add an Android app to it.
-   The **Package Name** must be `com.oeeez.oeon`.
-   Download the generated `google-services.json` and place it in the `android/app/` directory.

### 2.2 OAuth 2.0 Credentials

-   In the Google Cloud Console for your project, go to "APIs & Services" -> "Credentials".
-   Create an **OAuth 2.0 Client ID** for a **Web application**.
-   The **Client ID** from this credential is what you will use for the `GOOGLE_WEB_CLIENT_ID` in your `.env` file.
-   The **Client Secret** is used in the Supabase Google provider settings.

## 3. Local Project Configuration

### 3.1 `.env` File

Ensure your `.env` file at the project root contains the following keys with the correct values from the services above:

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
GOOGLE_WEB_CLIENT_ID=...
APP_REDIRECT_URI=io.supabase.flutterquickstart://login-callback/
CLERK_PUBLISHABLE_KEY=...
```

This guide ensures that any developer can set up the required environment for the TabL app to run.
