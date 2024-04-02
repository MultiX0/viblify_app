import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viblify_app/features/auth/controller/auth_controller.dart';

import '../../../core/common/big_button_widget.dart';
import '../../../core/common/input_form_widget.dart';
import '../../../core/common/leading_back_button.dart';
import '../../../theme/pallete.dart';

TextEditingController username = TextEditingController();
TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();

class RegistrationScreen extends ConsumerWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RegistrationScreen({super.key});

  RegExp get emailRegex => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  void validateAndSave(WidgetRef ref, BuildContext context) {
    final FormState form = formKey.currentState!;

    if (form.validate()) {
      // login(emailController.text, passwordController.text);
      ref.read(authControllerProvider.notifier).registerWithEmail(context,
          email.text.trim(), password.text.trim(), username.text.trim());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        username.clear();
        email.clear();
        password.clear();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.015,
                ),
                LeadingBackButton(
                  func: () {
                    username.clear();
                    email.clear();
                    password.clear();
                    context.pop();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height / 50,
                    ),
                    const Text("Registration",
                        style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            fontFamily: "FixelDisplay")),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "We're so excited to see you!",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: DenscordColors.textSecondary),
                      // textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height / 6.8,
                ),
                Column(
                  children: [
                    Form(
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        // key: controller.formKey,
                        child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "PICK A USERNAME",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: DenscordColors.textSecondary),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InputFormWidget(
                          text: "What should everyone call you?",
                          controller: username,
                          isPassword: false,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Username can\'t be empty!';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r"\s"))
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "You can always change this later!",
                            style: TextStyle(
                              color: DenscordColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "ACCOUNT INFORMATION",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: DenscordColors.textSecondary),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            InputFormWidget(
                              text: "Email",
                              controller: email,
                              isPassword: false,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Email can\'t be empty!';
                                } else if (!emailRegex.hasMatch(value)) {
                                  return 'Email are invalid!';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r"\s"))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            InputFormWidget(
                              text: "Password",
                              controller: password,
                              isPassword: true,
                              maxLenght: 72,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Password can\'t be empty!';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters long!';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r"\s"))
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Password must be 6-72 characters",
                                style: TextStyle(
                                  color: DenscordColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        BigButtonWidget(
                          text: "Register",
                          height: size.height / 19,
                          onPressed: () => validateAndSave(ref, context),
                          backgroundColor: DenscordColors.buttonPrimary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Text(
                            'By continuing, you agree to Viblify’s Terms of Use and Read our Privacy Policy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ))
                  ],
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
