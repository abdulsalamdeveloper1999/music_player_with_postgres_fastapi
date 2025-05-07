import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/viewmodel/auth_view_model.dart';
import 'package:client/features/auth/views/login_page.dart';
import 'package:client/features/auth/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/auth/widgets/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  List<TextEditingController> controllers =
      List.generate(3, (index) => TextEditingController());

  final List<String> hintTexts = [
    "Name",
    "Email",
    "Password",
  ];

  final List<IconData> fieldIcons = [
    Icons.person_outline,
    Icons.email_outlined,
    Icons.lock_outline,
  ];

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // ignore: avoid_function_literals_in_foreach_calls
    controllers.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  signup() async {
    ref.read(authViewModelProvider.notifier).signupUser(
          name: controllers[0].text,
          email: controllers[1].text,
          password: controllers[2].text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(authViewModelProvider.select((val) => val?.isLoading == true));

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          showSnackBar(
            content: 'Account created successfully',
            context: context,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        },
        error: (error, st) {
          showSnackBar(
            content: error.toString(),
            context: context,
            backgroundColor: Colors.red,
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: Color(0xFF121212), // Dark theme background
      body: isLoading
          ? LoaderWidget()
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E1E2E), // Dark purple
                    Color(0xFF0D0D14), // Near black
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background music-themed decorations
                  Positioned(
                    top: 70,
                    left: 30,
                    child: _buildMusicNote(
                        40, Color(0xFF6A3DE8).withValues(alpha: 0.3)),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 30,
                    child: _buildMusicNote(
                        50, Color(0xFFE83D7B).withValues(alpha: 0.3)),
                  ),
                  Positioned(
                    top: 200,
                    right: 50,
                    child: _buildEqualizerBars(
                        Color(0xFF3D7BE8).withValues(alpha: 0.3)),
                  ),

                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _globalKey,
                          child: Column(
                            children: [
                              SizedBox(height: 50),

                              // Back button and title
                              _buildHeader(context),
                              SizedBox(height: 30),

                              // Logo section
                              _buildLogoSection(),
                              SizedBox(height: 40),

                              // Form fields
                              _buildSignupFields(),
                              SizedBox(height: 30),

                              // Signup button
                              _buildSignupButton(),
                              SizedBox(height: 20),

                              // Login option
                              _buildLoginOption(context),
                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(width: 16),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFE83D7B), // Pink
                Color(0xFF6A3DE8), // Purple
              ],
            ),
          ),
          child: Icon(
            Icons.music_note,
            color: Colors.white,
            size: 35,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Join Rhythm',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Discover your perfect sound',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupFields() {
    return Column(
      children: List.generate(controllers.length, (index) {
        final bool isPasswordField = hintTexts[index] == "Password";

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomField(
            hintText: hintTexts[index],
            controller: controllers[index],
            validator: (value) => validateField(value, hintTexts[index]),
            prefixIcon: Icon(fieldIcons[index], color: Colors.white70),
            obscureText: isPasswordField,
          ),
        );
      }),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: AuthGradientButton(
        onPressed: () {
          if (_globalKey.currentState!.validate()) {
            signup();
          }
        },
        text: 'CREATE ACCOUNT',
        gradient: LinearGradient(
          colors: [
            Color(0xFFE83D7B), // Pink
            Color(0xFF6A3DE8), // Purple
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15),
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: Colors.white70),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Color(0xFFE83D7B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicNote(double size, Color color) {
    return Container(
      width: size,
      height: size * 1.5,
      child: CustomPaint(
        painter: MusicNotePainter(color: color),
      ),
    );
  }

  Widget _buildEqualizerBars(Color color) {
    return Container(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: EqualizerPainter(color: color),
      ),
    );
  }
}

// Custom painter for music note
class MusicNotePainter extends CustomPainter {
  final Color color;

  MusicNotePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw note head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.8),
        width: size.width * 0.6,
        height: size.width * 0.4,
      ),
      paint,
    );

    // Draw note stem
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.9,
        size.height * 0.2,
        size.width * 0.1,
        size.height * 0.6,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for equalizer bars
class EqualizerPainter extends CustomPainter {
  final Color color;

  EqualizerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 7;

    // Draw equalizer bars with varying heights
    final heights = [0.4, 0.7, 0.9, 0.5, 0.8, 0.3, 0.6];

    for (int i = 0; i < heights.length; i++) {
      final barHeight = size.height * heights[i];
      final barX = i * barWidth;
      final barY = size.height - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth * 0.7, barHeight),
          Radius.circular(barWidth * 0.3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
