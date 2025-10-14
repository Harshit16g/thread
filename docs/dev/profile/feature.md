# Profile Feature Documentation

This document outlines the profile management feature implementation in the TabL application, following clean architecture principles and maintaining consistency with the existing auth feature.

## 1. Directory Structure

The `profile` feature is self-contained within `lib/features/profile/` and follows clean architecture:

-   **/domain**: Contains the abstract business logic and entities.
    -   `entities/user_profile.dart`: Defines the `UserProfile` entity with user data.
    -   `repositories/profile_repository.dart`: Defines the contract for profile operations.
    
-   **/data**: Contains the implementation of repositories.
    -   `models/user_profile_model.dart`: Data model that extends `UserProfile` entity with JSON serialization.
    -   `repositories/profile_repository_impl.dart`: Concrete implementation with Supabase integration.
    
-   **/presentation**: Contains the UI and state management logic.
    -   `bloc/`: Holds all BLoC-related classes.
        -   `profile_bloc.dart`: Core state management for profile operations.
        -   `events/profile_event.dart`: Defines user-triggered events.
        -   `states/profile_state.dart`: Defines possible states of the profile UI.
    -   `screens/`: Contains the main UI widgets.
        -   `profile_screen.dart`: Main profile viewing screen.
        -   `profile_edit_screen.dart`: Profile editing screen with form validation.

## 2. Best Practices Implemented

✅ **Clean Architecture**: Clear separation of domain, data, and presentation layers
✅ **Dependency Injection**: Repositories and BLoCs injected via providers
✅ **State Management**: BLoC pattern for predictable state updates
✅ **Error Handling**: Try-catch blocks with user-friendly error messages
✅ **Type Safety**: Strong typing throughout with null safety
✅ **Reusability**: Shared widgets and modular components
✅ **Security**: RLS policies and proper authentication checks
✅ **Validation**: Form validation for data integrity
✅ **Documentation**: Comprehensive inline and external documentation
