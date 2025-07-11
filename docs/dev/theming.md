# Theming and UI Style Guide

This document defines the visual identity of the TabL application, ensuring a consistent and elegant user experience.

## 1. Color Palette

-   **Primary Brand Color**: `#075E54` (A deep, classic green). This is used for native elements like the adaptive icon background and splash screen.
-   **Primary Gradient**: A linear gradient from `#075E54` to `#128C7E` is used as the background for the Login and Sign-up screens to provide a rich, visually appealing backdrop.
-   **Glassmorphism Tint**: A semi-transparent "slate blue" (`Colors.blueGrey.withOpacity(0.25)`) is used for the glass-style buttons on the main authentication screen to ensure text is legible over the video background.
-   **Solid Button (Google)**: The primary call-to-action button uses a solid black background (`#000000`) with white text for high contrast and emphasis.

## 2. Typography

-   **Default Font**: The application uses the standard Flutter `MaterialApp` font, which defaults to Roboto on Android and San Francisco on iOS.
-   **Button Text**: Text on all major buttons uses a bold font weight (`FontWeight.bold`) and a font size of `16.0` for clarity and impact.

## 3. Component Library (`lib/shared/widgets/`)

To maintain consistency, we use a library of shared, reusable UI components.

### `AuthButton`

-   **Description**: A stateful, versatile button that serves as the primary action component in the app.
-   **Features**:
    -   **Drop Shadow**: A `BoxShadow` provides a "lift" effect, making the button feel tangible.
    -   **Pressed State**: The button provides visual feedback on press. Solid buttons invert their color, while glass buttons become more opaque.
    -   **Styles**: Supports two main styles via the `AuthButtonStyle` enum:
        -   `AuthButtonStyle.solid`: A solid-color button for primary actions (e.g., Google Sign-In).
        -   `AuthButtonStyle.glass`: A semi-transparent, blurred button for a modern glassmorphism effect.
    -   **Loading Indicator**: Displays a `CircularProgressIndicator` when its `isLoading` property is true.

### `GlassContainer` & `GlassAppBar`

-   **Description**: These widgets are the foundation of our "glassmorphism" UI.
-   **`GlassContainer`**: Uses a `BackdropFilter` with `ImageFilter.blur` to create a frosted glass effect over any content behind it. It supports customizable border radiuses.
-   **`GlassAppBar`**: A specialized, transparent `AppBar` built using `GlassContainer`, ensuring a consistent, elegant look on screens like Login and Sign-up.

### `CustomFormField`

-   **Description**: A standardized `TextFormField` with a consistent border radius and styling, used for all text input in the authentication flow.

This design system ensures that all parts of the app have a unified and polished look and feel.
