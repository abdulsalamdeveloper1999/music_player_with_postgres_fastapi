import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/viewmodel/auth_view_model.dart';
import 'package:client/features/auth/views/signup_page.dart';
import 'package:client/features/auth/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/widgets/utils.dart';
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

    return Scaffold(
      body: isLoading
          ? LoaderWidget()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _globalKey,
                child: Column(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...List.generate(controllers.length, (index) {
                      return CustomField(
                        hintText: hintTexts[index],
                        controller: controllers[index],
                        validator: (value) =>
                            validateField(value, hintTexts[index]),
                      );
                    }),
                    AuthGradientButton(
                      onPressed: () {
                        if (_globalKey.currentState!.validate()) {
                          login();
                        }
                      },
                      text: 'Login',
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SignUpPage()));
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Dont have an account? '),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Pallete.gradient2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
