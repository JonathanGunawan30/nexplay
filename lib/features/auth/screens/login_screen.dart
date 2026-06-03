import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    if (authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        authProvider.clearError();
      });
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.indigo.withAlpha(isDark ? 40 : 20),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.indigo.withAlpha(isDark ? 50 : 30)),
                ),
                child: Icon(
                  Icons.sports_esports_rounded,
                  size: 72,
                  color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'NexPlay',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level up your gaming experience',
                style: TextStyle(
                  fontSize: 15,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 64),

              if (authProvider.isLoading)
                Container(
                  width: double.infinity,
                  height: 128,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800.withAlpha(100) : Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authenticating with Provider...',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _SocialLoginButton(
                  onPressed: () => authProvider.signInWithGoogle(),
                  icon: SvgPicture.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    height: 22,
                  ),
                  label: 'Sign in with Google',
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                  textColor: isDark ? Colors.white : const Color(0xFF1E293B),
                  hasBorder: !isDark,
                ),
                const SizedBox(height: 16),
                _SocialLoginButton(
                  onPressed: () => authProvider.signInWithGitHub(),
                  icon: SvgPicture.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/github.svg',
                    height: 22,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  label: 'Sign in with GitHub',
                  backgroundColor: isDark ? Colors.black : const Color(0xFF0F172A),
                  textColor: Colors.white,
                  hasBorder: false,
                ),
              ],

              const SizedBox(height: 48),
              Text(
                'NexPlay - Your Premium Gaming Hub',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade600 : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool hasBorder;

  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.hasBorder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: hasBorder ? 0 : 4,
          shadowColor: Colors.black.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: hasBorder ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
