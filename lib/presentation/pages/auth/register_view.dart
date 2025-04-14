// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/auth_widget.dart';
import 'register_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class RegisterView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Consumer<RegisterViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/images/auth/auth_img.png',
                      height: 220,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reciply',
                    style: AppTextStyle.reciplyLogo.copyWith(
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withAlpha(51),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AuthTextField(
                    label: "Nom d'utilisateur",
                    controller: _usernameController,
                    prefixIcon: const Icon(Icons.person),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 17),
                  AuthTextField(
                    label: "Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return "Veuillez entrer l'adresse email !";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 17),
                  AuthTextField(
                    label: "Mot de passe",
                    controller: _passwordController,
                    prefixIcon: const Icon(Icons.password),
                    obscureText: true,
                    validator: (password) {
                      if (password == null || password.isEmpty) {
                        return "Veuillez entrer le mot de passe";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  AuthButton(
                    text: "S'inscrire",
                    isLoading: viewModel.isLoading,
                    onPressed: () async {
                      final username = _usernameController.text;
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      if (username.isNotEmpty &&
                          email.isNotEmpty &&
                          password.isNotEmpty) {
                        await viewModel.register(
                          username: username,
                          email: email,
                          password: password,
                        );

                        if (viewModel.errorMessage != null) {
                          final isEmailInUse = viewModel.errorMessage!
                              .toLowerCase()
                              .contains("email");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEmailInUse
                                    ? "Email déjà utilisé"
                                    : "Authentification non réussie",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, '/welcome');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthNavigationText(
                    question: "Déjà un compte ? ",
                    actionText: "Se connecter",
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
