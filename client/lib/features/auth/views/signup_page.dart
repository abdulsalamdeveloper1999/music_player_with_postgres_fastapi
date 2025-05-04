import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/viewmodel/auth_view_model.dart';
import 'package:client/features/auth/views/login_page.dart';
import 'package:client/features/auth/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/widgets/utils.dart';
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

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // ignore: avoid_function_literals_in_foreach_calls
    controllers.forEach((controller) {
      controller.dispose();
    });
    // _globalKey.currentState!.validate();
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
                      'Sign Up',
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
                          signup();
                        }
                      },
                      text: 'Sign Up',
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
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
