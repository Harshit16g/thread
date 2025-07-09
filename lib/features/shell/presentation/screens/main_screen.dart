import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../connect/presentation/screens/connect_screen.dart';
import '../../../../core/services/local_auth_service.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final LocalAuthService _localAuthService = LocalAuthService();
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    ConnectScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptForBiometrics();
    });
  }

  Future<void> _checkAndPromptForBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPrompt = prefs.getBool('hasSeenBiometricPrompt') ?? false;

    // Guard with a mounted check before using context across an async gap.
    if (!mounted) return;

    if (!hasSeenPrompt) {
      await prefs.setBool('hasSeenBiometricPrompt', true);

      final canCheckBiometrics = await _localAuthService.canCheckBiometrics;
      if (canCheckBiometrics && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enable Biometric Unlock'),
            content: const Text('Would you like to use your fingerprint or face to unlock the app and protect your data?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe Later'),
              ),
              TextButton(
                onPressed: () async {
                  final didAuthenticate = await _localAuthService.authenticate('Please authenticate to enable biometrics');
                  
                  if (!mounted) return;
                  
                  if (didAuthenticate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometrics enabled!')),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Enable'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Connect'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
