import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Champ de saisie générique avec animations
class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Duration animationDuration;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _labelAnimation;
  late Animation<double> _fieldAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..forward();

    _labelAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _fieldAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animation pour le label
        ScaleTransition(
          scale: _labelAnimation,
          child: FadeTransition(
            opacity: _labelAnimation,
            child: Text(
              widget.label,
              style: AppTextStyle.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Animation pour le champ de texte
        ScaleTransition(
          scale: _fieldAnimation,
          child: FadeTransition(
            opacity: _fieldAnimation,
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              style: AppTextStyle.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent.withAlpha(76)),
                  borderRadius: BorderRadius.circular(0),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error.withAlpha(200)),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              validator: widget.validator,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouton d'authentification avec animations
class AuthButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Duration animationDuration;

  const AuthButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor?.withAlpha(70),
      end: widget.backgroundColor,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorAnimation.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: widget.isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 3,
                      )
                    : Text(
                        widget.text,
                        style: AppTextStyle.button.copyWith(fontSize: 18),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lien de navigation avec animation
class AuthNavigationText extends StatefulWidget {
  final String question;
  final String actionText;
  final VoidCallback onTap;
  final Duration animationDelay;

  const AuthNavigationText({
    super.key,
    required this.question,
    required this.actionText,
    required this.onTap,
    this.animationDelay = const Duration(milliseconds: 200),
  });

  @override
  State<AuthNavigationText> createState() => _AuthNavigationTextState();
}

class _AuthNavigationTextState extends State<AuthNavigationText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(widget.animationDelay, () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.question,
              style: AppTextStyle.subtitle.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: widget.onTap,
              child: Text(
                widget.actionText,
                style: AppTextStyle.subtitle.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
