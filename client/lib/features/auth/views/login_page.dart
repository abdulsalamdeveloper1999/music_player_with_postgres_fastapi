import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/music_theme.dart';
import 'package:client/features/auth/viewmodel/auth_view_model.dart';
import 'package:client/features/auth/views/signup_page.dart';
import 'package:client/features/auth/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/utils.dart';
import 'package:client/features/auth/widgets/validator.dart';
import 'package:client/features/home/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  List<TextEditingController> controllers =
      List.generate(2, (index) => TextEditingController());

  final List<String> hintTexts = [
    "Email",
    "Password",
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

  login() async {
    ref.read(authViewModelProvider.notifier).loginUser(
          email: controllers[0].text,
          password: controllers[1].text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(authViewModelProvider.select((val) => val?.isLoading == true));

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => HomePage()));
        },
        error: (error, stack) {
          showSnackBar(
            content: error.toString(),
            context: context,
            backgroundColor: Colors.red,
          );
        },
        loading: () {},
      );
    });

    return MusicThemeBackground(
      child: Scaffold(
        // backgroundColor: Color(0xFF121212), // Dark theme background
        backgroundColor: Colors.transparent,
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

                    // Main content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _globalKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 80),

                                // Logo and title
                                _buildLogoSection(),
                                SizedBox(height: 40),

                                // Login form
                                _buildLoginFields(),
                                SizedBox(height: 30),

                                // Login button
                                _buildLoginButton(),
                                SizedBox(height: 20),

                                // Signup option
                                _buildSignupOption(context),
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
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
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
            size: 40,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Rhythm',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Your music companion',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        // Email field with custom styling
        Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomField(
            hintText: hintTexts[0],
            controller: controllers[0],
            validator: (value) => validateField(value, hintTexts[0]),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
          ),
        ),

        // Password field with custom styling
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomField(
            hintText: hintTexts[1],
            controller: controllers[1],
            validator: (value) => validateField(value, hintTexts[1]),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
            obscureText: true,
          ),
        ),

        // Forgot password option
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xFF6A3DE8),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: AuthGradientButton(
        onPressed: () {
          if (_globalKey.currentState!.validate()) {
            login();
          }
        },
        text: 'LOGIN',
        gradient: LinearGradient(
          colors: [
            Color(0xFFE83D7B), // Pink
            Color(0xFF6A3DE8), // Purple
          ],
        ),
      ),
    );
  }

  Widget _buildSignupOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignUpPage()),
        );
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15),
          children: [
            TextSpan(
              text: 'Don\'t have an account? ',
              style: TextStyle(color: Colors.white70),
            ),
            TextSpan(
              text: 'Sign Up',
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
}
