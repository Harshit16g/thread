# Proposed Authentication Flow Updates

This document outlines two key proposals:
1.  Enhancing the Google Sign-In user experience to use a native bottom sheet.
2.  A comprehensive URL configuration guide using the custom domain `oeeez.online` for a more professional and secure authentication flow.

---

## 1. Google Sign-In Native Bottom Sheet UI

### The Goal
The current request is to replace the default rectangular pop-up for Google Sign-In with a more modern, native-feeling bottom sheet that has rounded corners. This provides a smoother and more integrated user experience.

### Analysis & Proposal
The good news is that the application is already correctly configured to achieve this. The native bottom-sheet UI is the **standard behavior** provided by the Google Sign-In SDK on modern Android and iOS devices.

The key is the distinction between two sign-in methods:
- **Web-Based OAuth**: This method opens a web browser or a web-view within the app. It can feel disconnected and is what often results in a generic rectangular container.
- **Native SDK Sign-In**: This method uses the device's built-in Google account manager, which presents the familiar, native bottom-sheet UI.

Your current implementation in `lib/features/auth/data/repositories/auth_repository_impl.dart` **correctly uses the native SDK flow**:
```dart
// This code correctly invokes the native Google Sign-In flow
final googleUser = await _googleSignIn.signIn(); 
// ... then passes the token to Supabase
await _supabase.auth.signInWithIdToken(...);
```
By calling `_googleSignIn.signIn()`, you are asking the OS to handle the sign-in, which results in the desired bottom-sheet UI on supported devices. No code changes are required to enable this, as it is the correct implementation path.

**Conclusion**: The app is already using the best practice for a native Google Sign-In experience. The desired UI will appear automatically for users on up-to-date mobile operating systems.

---

## 2. URL Configuration with a Custom Domain

Using your domain `oeeez.online` for authentication is a crucial step for branding, security, and user trust. It ensures that users see a familiar URL throughout the process.

Here is a definitive list of the URLs you will need and how to configure them.

### URL 1: Custom Auth Domain
This is the main, user-facing URL for your backend services.

- **URL**: `https://auth.oeeez.online`
- **Purpose**: Acts as a branded alias for your Supabase project URL. All communication from your app to Supabase will go through this domain.
- **Setup**:
    1.  In your DNS provider for `oeeez.online`, create a `CNAME` record.
    2.  Point the subdomain `auth` to your actual Supabase URL: `auth.oeeez.online. CNAME <YOUR-PROJECT-REF>.supabase.co.`
    3.  In your Supabase project dashboard, go to `Settings` -> `Custom Domains` and add `auth.oeeez.online`.
    4.  Update the `SUPABASE_URL` in your app's `.env` file to `https://auth.oeeez.online`.

### URL 2: Google OAuth Callback URL
This URL tells Google where to send the user back to after they approve the login.

- **URL**: `https://auth.oeeez.online/auth/v1/callback`
- **Purpose**: A secure endpoint on your Supabase backend (accessed via your custom domain) that receives the authentication token from Google.
- **Setup**:
    1.  Go to your **Google Cloud Console** -> `APIs & Services` -> `Credentials`.
    2.  Select your OAuth 2.0 Client ID.
    3.  Under "Authorized redirect URIs", add `https://auth.oeeez.online/auth/v1/callback`.

### URL 3: App Deep Link (Redirect URL)
This URL is used by Supabase to redirect the user from the web back into your mobile application after authentication or email verification.

#### Option A: Custom Scheme (Current Method)
- **URL**: `io.supabase.tabl://login-callback/`
- **Pros**: Simple to set up and requires no web hosting.
- **Cons**: Can sometimes show a confirmation dialog to the user before opening the app.
- **Setup**: This is already correctly configured in your `AndroidManifest.xml`. No changes are needed if you stick with this method.

#### Option B: Universal Link / App Link (Recommended for Production)
- **URL**: `https://app.oeeez.online/auth/callback`
- **Pros**: Provides a seamless user experience by opening the app directly without any pop-ups. Falls back to a webpage if the app isn't installed.
- **Cons**: Requires more setup.
- **Setup**:
    1.  **Web**: Host a file at `https://app.oeeez.online/.well-known/assetlinks.json` for Android and `https://app.oeeez.online/.well-known/apple-app-site-association` for iOS to prove ownership of the domain.
    2.  **App**: Update the `<intent-filter>` in `AndroidManifest.xml` to handle this `https://` scheme.
    3.  **Supabase**: In your Supabase Dashboard under `Authentication` -> `URL Configuration`, update the **Site URL** and **Redirect URLs** to `https://app.oeeez.online/auth/callback`.

### URL 4: Email Verification URL
This is the base URL used in automated emails (e.g., "Confirm your email").

- **URL**: `https://auth.oeeez.online`
- **Purpose**: Ensures that links in your emails are branded and trusted.
- **Setup**:
    1.  In your Supabase Dashboard, go to `Authentication` -> `Email Templates`.
    2.  Modify the templates (e.g., "Confirm signup", "Magic Link") to use your custom domain for all generated links. The templates will automatically append the necessary paths and tokens. For example, the "Confirm signup" link will become `https://auth.oeeez.online/auth/v1/verify?token=...&type=signup&redirect_to=...`.
