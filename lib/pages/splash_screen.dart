import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({super.key, required this.onAnimationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _faceController;
  late AnimationController _backgroundController;
  late AnimationController _textController;

  late Animation<double> _faceScaleAnimation;
  late Animation<double> _faceRotationAnimation;
  late Animation<double> _eyeAnimation;
  late Animation<double> _mouthAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Face scale and rotation animation
    _faceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Backgrounds gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Text fade animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Face animations
    _faceScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _faceController,
      curve: Curves.elasticOut,
    ));

    _faceRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _faceController,
      curve: Curves.easeOutBack,
    ));

    _eyeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _faceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));

    _mouthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _faceController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeInOut),
    ));

    // Background animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Text animation
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _faceController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    // Complete animation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _faceController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade900,
                  Colors.indigo.shade800,
                  Colors.blue.shade900,
                  Colors.purple.shade900,
                ],
                stops: [
                  0.0,
                  0.3 + _backgroundAnimation.value * 0.2,
                  0.7 + _backgroundAnimation.value * 0.2,
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating background elements
                ...List.generate(30, (index) => _buildFloatingElement(index)),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedFace(),
                      const SizedBox(height: 40),
                      _buildAnimatedText(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned(
          left: (index * 35.0) % MediaQuery.of(context).size.width,
          top: (index * 25.0 + _backgroundAnimation.value * 60) %
              MediaQuery.of(context).size.height,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(_backgroundAnimation.value * 6.28)
              ..scale(0.2 + _backgroundAnimation.value * 0.8),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFace() {
    return AnimatedBuilder(
      animation: _faceController,
      builder: (context, child) {
        // Rolling animation for the emoji
        double rotation = _faceRotationAnimation.value * 2 * 3.14; // Full roll
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..scale(_faceScaleAnimation.value)
            ..rotateZ(rotation),
          child: Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            child: Text(
              '😂',
              style: TextStyle(
                fontSize: 120,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, -_textAnimation.value * 20)
            ..scale(0.8 + _textAnimation.value * 0.2),
          child: Opacity(
            opacity: _textAnimation.value,
            child: Column(
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'EQC Meme App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.yellow.shade400,
                        Colors.yellow.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw a big happy smile (arc, lower, more curve)
    final smileRect = Rect.fromLTWH(
      size.width * 0.18, // left margin
      size.height * 0.45, // lower arc
      size.width * 0.64, // width
      size.height * 0.35, // height (more curve, less creepy)
    );
    canvas.drawArc(smileRect, 0.15 * 3.14, 0.7 * 3.14, false, paint);

    // Add two small cheek dots for extra happiness
    final cheekPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.32, size.height * 0.82), 2.5, cheekPaint);
    canvas.drawCircle(
        Offset(size.width * 0.68, size.height * 0.82), 2.5, cheekPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
