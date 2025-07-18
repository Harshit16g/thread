# TabL: Contribution Guidelines
*Version 1.0, January 2025*

---

## Introduction
Thank you for your interest in contributing to the TabL Super-App! These guidelines are designed to ensure a smooth, consistent, and effective development workflow for everyone involved.

By following these guidelines, you help us maintain a high standard of code quality and architectural integrity. Before you begin, please make sure you have read and understood the **[Architectural Foundation document](./Architectural_Foundation_and_Integration_Strategy.md)**.

---

## 1. Code of Conduct
All contributors are expected to adhere to a professional and respectful code of conduct. We are building a collaborative community, and all interactions should be positive and constructive.

---

## 2. Setting Up Your Development Environment
1.  **Install Flutter**: Ensure you have the latest stable version of the Flutter SDK installed.
2.  **Clone the Repository**: `git clone <repository_url>`
3.  **Create Your Environment File**:
    -   Copy the `.env.example` file to a new file named `.env.dev`.
    -   Fill in the required credentials for the development Supabase project. **Do not use production keys in your development environment.**
4.  **Install Dependencies**: Run `flutter pub get` in your terminal.
5.  **Run the App**: Launch the app using the development environment configuration:
    ```bash
    flutter run --dart-define-from-file=.env.dev
    ```

---

## 3. Branching Strategy
We use a simplified GitFlow branching model.

-   `main`: This branch represents the latest stable, production-ready code. Direct pushes to `main` are forbidden.
-   `develop`: This is the primary development branch. All feature branches are created from `develop` and merged back into it.
-   **Feature Branches**: All new features, bug fixes, or enhancements should be developed on a dedicated feature branch.

#### **Branch Naming Convention:**
-   **Features**: `feature/<feature-name>` (e.g., `feature/wallet-transactions`)
-   **Bug Fixes**: `fix/<bug-description>` (e.g., `fix/login-button-overflow`)
-   **Chores/Refactoring**: `chore/<task-description>` (e.g., `chore/refactor-auth-widgets`)

---

## 4. The Development Workflow
1.  **Pull the Latest `develop`**: Before starting any new work, ensure your `develop` branch is up to date: `git checkout develop && git pull origin develop`.
2.  **Create a Feature Branch**: Create your new branch from `develop`: `git checkout -b feature/your-feature-name`.
3.  **Develop Your Feature**:
    -   Write your code, following the architectural patterns and coding style.
    -   Ensure your feature is self-contained within a feature directory (`lib/features/your_feature`).
    -   Add comments to your code where necessary to explain complex logic.
4.  **Run Local Checks**: Before submitting your code for review, run the following checks locally:
    -   `flutter analyze` to check for any static analysis issues.
    -   `flutter test` to ensure all existing and new tests are passing.
5.  **Submit a Pull Request**:
    -   Push your feature branch to the remote repository.
    -   Create a new Pull Request (PR) from your feature branch into the `develop` branch.
    -   Fill out the **[Pull Request Template](./PULL_REQUEST_TEMPLATE.md)** completely. A well-documented PR is much easier and faster to review.

---

## 5. Coding Style and Standards
-   **Linting**: We adhere to the rules defined in the `analysis_options.yaml` file. Please ensure your code has no linting errors before submitting a PR.
-   **Formatting**: We use the default Flutter code formatter (`dart format`).
-   **Immutability**: Strive to use immutable data structures wherever possible. Use `const` for constructors where applicable.
-   **Final Fields**: Class fields should be `final` unless they are explicitly designed to be mutable.

---

## 6. Code Reviews
-   All pull requests must be reviewed and approved by at least one other developer before being merged.
-   Reviewers should provide clear, constructive feedback.
-   The author of the PR is responsible for addressing all comments and ensuring their code meets the project standards before the PR is merged.
