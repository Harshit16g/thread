# Quick Start Guide - TabL Application

This guide will help you get the TabL application up and running quickly.

## Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK** (3.5.0 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**
- **Supabase Account** (free tier available)

## Step 1: Clone the Repository

```bash
git clone https://github.com/Harshit16g/thread.git
cd thread
```

## Step 2: Install Dependencies

```bash
flutter pub get
```

## Step 3: Set Up Supabase Backend

### 3.1 Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in
3. Create a new project
4. Note down your project URL and anon key

### 3.2 Set Up Database

1. In Supabase dashboard, go to SQL Editor
2. Copy the contents of `supabase/migrations/20250114_create_profiles.sql`
3. Paste and run in SQL Editor
4. Verify the `profiles` table and `avatars` storage bucket are created

### 3.3 Configure Authentication Providers

**For Email/Password (default enabled)**:
1. Go to Authentication > Providers
2. Enable "Email" provider
3. Enable "Confirm email" for verification flow

**For Google Sign-In (optional)**:
1. Create a project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable Google+ API
3. Create OAuth 2.0 credentials (Web client)
4. Note down the Web Client ID and Client Secret
5. In Supabase dashboard:
   - Go to Authentication > Providers
   - Enable Google provider
   - Add your Web Client ID and Client Secret
   - Add authorized redirect URIs

## Step 4: Configure Environment Variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
GOOGLE_WEB_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
APP_REDIRECT_URI=io.supabase.flutterquickstart://login-callback/
```

**Important**: Never commit the `.env` file to version control!

## Step 5: Run the Application

### For Android:

```bash
# List available devices
flutter devices

# Run on connected device or emulator
flutter run
```

### For iOS (macOS only):

```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

### For Web:

```bash
flutter run -d chrome
```

## Step 6: Test the Application

### Test Authentication:
1. Launch the app - you should see the video background auth screen
2. Tap "Sign Up" to create a new account
3. Enter email and password
4. Check your email for verification link
5. Click the link to verify
6. Sign in with your credentials

### Test Profile Management:
1. After signing in, you'll see the home screen with bottom navigation
2. Tap the "Profile" tab
3. You should see your profile information
4. Tap "Edit Profile" to update your information
5. Make changes and tap "Save Changes"
6. Verify changes are reflected in the profile view

### Test Logout:
1. On the profile screen, tap "Logout"
2. Confirm the logout
3. You should be redirected to the auth screen

## Project Structure Overview

```
lib/
├── features/
│   ├── auth/              # Authentication feature
│   ├── profile/           # Profile management feature
│   ├── home/              # Home screen (placeholder)
│   ├── search/            # Search feature (placeholder)
│   ├── connect/           # Connect feature (placeholder)
│   └── shell/             # Main navigation shell
├── shared/
│   └── widgets/           # Reusable UI components
├── core/
│   ├── services/          # App services
│   └── theme/             # Theming
├── auth_gate.dart         # Auth state router
└── main.dart              # App entry point
```

## Common Issues and Solutions

### Issue: "flutter: command not found"
**Solution**: Make sure Flutter is added to your PATH. Run:
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: "Supabase URL or Key not set"
**Solution**: Ensure your `.env` file is in the project root and contains valid values.

### Issue: "Profile not created on signup"
**Solution**: 
1. Check if the database trigger is installed
2. Run the migration script again
3. Check Supabase logs for errors

### Issue: "Google Sign-In fails"
**Solution**:
1. Verify Web Client ID is correct in `.env`
2. Check Google Cloud Console credentials
3. Ensure authorized redirect URIs are configured

### Issue: "Cannot upload avatar"
**Solution**:
1. Verify `avatars` storage bucket exists in Supabase
2. Check storage policies are properly configured
3. Install image picker package (coming soon)

## Development Workflow

### Adding New Features

1. Create feature branch:
```bash
git checkout -b feat/new-feature
```

2. Follow clean architecture structure:
```
lib/features/your_feature/
├── domain/
│   ├── entities/
│   └── repositories/
├── data/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── screens/
    └── widgets/
```

3. Implement BLoC for state management
4. Create UI screens with proper error handling
5. Update dependency injection in `main.dart`
6. Add documentation
7. Commit and push

### Code Style

The project uses `flutter_lints` for code analysis. Run:
```bash
flutter analyze
```

### Running Tests

```bash
flutter test
```

## Architecture Highlights

- **Clean Architecture**: Separation of domain, data, and presentation layers
- **BLoC Pattern**: Predictable state management
- **Feature-First**: Modular, scalable structure
- **Dependency Injection**: Using flutter_bloc providers
- **Glass Morphism UI**: Modern, elegant design

## Documentation

For detailed documentation, see:
- [Architecture Guide](docs/dev/architecture.md)
- [Profile Feature](docs/dev/profile/feature.md)
- [Database Setup](docs/DATABASE_SETUP.md)
- [Issues & Improvements](docs/ISSUES_AND_IMPROVEMENTS.md)

## Getting Help

- Check existing documentation in `docs/`
- Review inline code comments
- Check Supabase documentation: https://supabase.com/docs
- Flutter documentation: https://flutter.dev/docs

## Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests if applicable
5. Update documentation
6. Submit a pull request

See [CONTRIBUTING.md](docs/Contribution.md) for detailed guidelines.

## License

MIT License - see LICENSE file for details

---

**Happy Coding! 🚀**

Built with ❤️ using Flutter, Supabase, and modern architecture principles.
