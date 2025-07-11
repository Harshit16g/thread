import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/auth_options_panel.dart'; // Import the new panel

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/animations/splashscreen.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video background
          FittedBox(
            fit: BoxFit.cover,
            child: _controller.value.isInitialized
                ? SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  )
                : const SizedBox(),
          ),
          // Auth options UI
          const AuthOptionsPanel(),
        ],
      ),
    );
  }
}
