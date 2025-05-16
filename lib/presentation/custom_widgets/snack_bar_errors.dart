import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBarErrors(
    {required BuildContext context, required String text}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: whiteColor,
      content: Text(text, style: const TextStyle(color: Colors.red)),
    ),
  );
}

void showCustomPositionedSnackBar({
  required BuildContext context,
  required String title,
  required String message,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 70, // Custom position from the top
      left: 5, // Custom position from the left
      right: 5, // Custom position from the right
      child: AnimatedSnackBar(
        title: title,
        message: message,
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Remove the snackbar after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

class AnimatedSnackBar extends StatefulWidget {
  final String title;
  final String message;

  const AnimatedSnackBar({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  _AnimatedSnackBarState createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0), // Start from above screen
      end: const Offset(0.0, 0.0), // Drop to position and bounce
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut, // Add bouncing effect
    ));

    // Start the animation as soon as the widget builds
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.transparent, // Make the background transparent
          child: AwesomeSnackbarContent(
            title: widget.title,
            message: widget.message,
            contentType: ContentType.success,
            titleTextStyle: const TextStyle(fontSize: 24),
            messageTextStyle: const TextStyle(fontSize: 16),
            color:
                const Color.fromARGB(255, 93, 215, 97), // Lighter green color
          ),
        ),
      ),
    );
  }
}

void showCustomPositionedSnackBarError({
  required BuildContext context,
  required String title,
  required String message,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 70, // Custom position from the top
      left: 5, // Custom position from the left
      right: 5, // Custom position from the right
      child: AnimatedSnackBarError(
        title: title,
        message: message,
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Remove the snackbar after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

class AnimatedSnackBarError extends StatefulWidget {
  final String title;
  final String message;

  const AnimatedSnackBarError({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  _AnimatedSnackBarErrorState createState() => _AnimatedSnackBarErrorState();
}

class _AnimatedSnackBarErrorState extends State<AnimatedSnackBarError>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0), // Start from above screen
      end: const Offset(0.0, 0.0), // Drop to position and bounce
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut, // Add bouncing effect
    ));

    // Start the animation as soon as the widget builds
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.transparent,
          child: AwesomeSnackbarContent(
              title: widget.title,
              message: widget.message,
              contentType: ContentType.failure,
              titleTextStyle: const TextStyle(fontSize: 24),
              messageTextStyle: const TextStyle(fontSize: 16),
              color: Colors.red),
        ),
      ),
    );
  }
}
