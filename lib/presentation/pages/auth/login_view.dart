// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_viewmodel.dart';
import '../../widgets/auth_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Consumer<LoginViewModel>(
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
                    label: 'Email',
                    controller: viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 17),

                  AuthTextField(
                    label: 'Mot de passe',
                    controller: viewModel.passwordController,
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final email = viewModel.emailController.text;
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Veuillez entrer votre email',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        final result = await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text(
                                  'Réinitialisation du mot de passe',
                                ),
                                content: Text(
                                  'Un email de réinitialisation sera envoyé à $email. Continuer ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Envoyer'),
                                  ),
                                ],
                              ),
                        );

                        if (result == true) {
                          final resetResult = await viewModel.resetPassword(
                            email,
                          );
                          if (resetResult == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Email de réinitialisation envoyé à $email. Vérifiez votre boîte mail.',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } else {
                            String errorMessage;
                            switch (resetResult) {
                              case 'user-not-found':
                                errorMessage =
                                    'Aucun utilisateur trouvé avec cet email';
                                break;
                              default:
                                errorMessage =
                                    'Une erreur est survenue. Veuillez réessayer plus tard.';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyle.body.copyWith(
                          color: AppColors.primary.withAlpha(204),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AuthButton(
                    text: 'Connexion',
                    isLoading: viewModel.isLoading,
                    onPressed: () {
                      if (viewModel.emailController.text.isNotEmpty &&
                          viewModel.passwordController.text.isNotEmpty) {
                        viewModel
                            .login(
                              email: viewModel.emailController.text,
                              password: viewModel.passwordController.text,
                            )
                            .then((result) {
                              if (result == 'success') {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              } else if (result == 'user_not_found') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Utilisateur inexistant',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Email ou mot de passe incorrect',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  AuthNavigationText(
                    question: 'Pas de compte ? ',
                    actionText: 'Créer un compte',
                    onTap: () => Navigator.pushNamed(context, '/signup'),
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
