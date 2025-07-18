# TabL: UI Design System & Theming Guide
*Version 1.0, January 2025*

---

## 1. Introduction
This document provides a comprehensive guide to the UI Design System for the TabL application. Its purpose is to ensure a consistent, accessible, and visually appealing user experience across all features and platforms.

All UI development should adhere to the standards defined in this document. The core theme files are located in `lib/core/theme/`.

## 2. Core Design Principles
-   **Clarity**: The UI should be clean, intuitive, and easy to navigate.
-   **Consistency**: Components, colors, and typography should be used consistently throughout the app to create a unified experience.
-   **Accessibility**: The app must be usable by everyone. This includes providing sufficient color contrast, supporting dynamic font sizes, and ensuring screen reader compatibility.
-   **Feedback**: The UI should provide immediate and clear feedback for all user interactions through animations, loading states, and haptics.

## 3. Color System
We use a structured color system based on Material Design 3 principles. The primary color palette is defined in `lib/core/theme/app_colors.dart`.

| Name                 | Light Theme                                   | Dark Theme                                    | Usage                               |
| -------------------- | --------------------------------------------- | --------------------------------------------- | ----------------------------------- |
| **Primary**          | `0xFF6750A4` (Deep Purple)                    | `0xFFD0BCFF` (Light Purple)                   | Interactive elements, buttons, FABs |
| **On Primary**       | `0xFFFFFFFF` (White)                          | `0xFF381E72` (Dark Purple)                    | Text/icons on top of Primary      |
| **Primary Container**| `0xFFEADDFF` (Light Purple)                   | `0xFF4F378B` (Medium Purple)                  | Backgrounds for primary elements  |
| **Secondary**        | `0xFF625B71` (Medium Gray)                    | `0xFFCCC2DC` (Light Gray)                     | Secondary buttons, filters        |
| **Surface**          | `0xFFFFFBFE` (Near White)                     | `0xFF1C1B1F` (Near Black)                     | Card backgrounds, sheets, dialogs |
| **On Surface**       | `0xFF1C1B1F` (Near Black)                     | `0xFFE6E1E5` (Light Gray)                     | Primary text color                |
| **On Surface Variant**| `0xFF49454F` (Gray)                           | `0xFFCAC4D0` (Gray)                           | Secondary text, subtitles, hints  |
| **Error**            | `0xFFB3261E` (Red)                            | `0xFFF2B8B5` (Light Red)                      | Error messages, invalid fields    |
| **Success (Custom)** | `0xFF2E7D32` (Green)                          | `0xFF66BB6A` (Light Green)                    | Success indicators, confirmations |

---

## 4. Typography System
Our typography system, defined in `lib/core/theme/app_text_styles.dart`, provides a hierarchy of text styles for different purposes.

| Style Name          | Font Size | Font Weight | Usage                               |
| ------------------- | --------- | ----------- | ----------------------------------- |
| `displayLarge`      | 57        | `w400`      | Hero text, large screen titles      |
| `headlineLarge`     | 32        | `w400`      | Screen titles                       |
| `titleLarge`        | 22        | `w500`      | Card titles, dialog titles        |
| `titleMedium`       | 16        | `w500`      | List item titles, subtitles       |
| `bodyLarge`         | 16        | `w400`      | Main body text, descriptions      |
| `bodyMedium`        | 14        | `w400`      | Secondary body text, captions     |
| `labelLarge`        | 14        | `w500`      | Button text, interactive labels   |

---

## 5. Spacing System
Consistent spacing is crucial for a clean layout. We use a base unit of `8.0` pixels. Spacing constants are defined in `lib/core/constants/app_spacing.dart`.

| Name    | Value  | Usage                                   |
| ------- | ------ | --------------------------------------- |
| `xs`    | `4.0`  | Extra small padding, icon spacing       |
| `sm`    | `8.0`  | Small padding within components         |
| `md`    | `16.0` | Standard padding between components     |
| `lg`    | `24.0` | Large padding for screen sections       |
| `xl`    | `32.0` | Extra large padding                     |

---

## 6. Core UI Component Library
To ensure consistency, all developers should use the shared widgets from `lib/shared/widgets/` whenever possible.

### `PrimaryButton`
-   **Purpose**: The standard call-to-action button.
-   **Usage**:
    ```dart
    PrimaryButton(
      onPressed: () { /* ... */ },
      text: 'Confirm Action',
      isLoading: state is AuthLoading,
    )
    ```

### `GlassContainer`
-   **Purpose**: A container with a frosted glass effect, used for app bars, bottom navigation, and cards.
-   **Usage**:
    ```dart
    GlassContainer(
      borderRadius: 16.0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text('Frosted Glass Content'),
      ),
    )
    ```

### `CustomFormField`
-   **Purpose**: The standard text input field for all forms.
-   **Usage**:
    ```dart
    CustomFormField(
      controller: _emailController,
      labelText: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: (value) => Validators.validateEmail(value),
    )
    ```
---

## 7. Iconography
-   **Primary Icon Set**: We will use the standard Material Icons provided by the Flutter SDK.
-   **Custom Icons**: Any custom icons (e.g., for the native token) should be in SVG format and stored in `assets/icons/`.
