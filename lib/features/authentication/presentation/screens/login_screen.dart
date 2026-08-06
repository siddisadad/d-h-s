import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && mounted) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.enterEmailPassword)),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', email);
    } else {
      await prefs.remove('remembered_email');
    }

    await ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(context),
                SizedBox(height: tokens.space32),
                
                CustomCard(
                  padding: EdgeInsets.all(tokens.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.secureLogin,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.secureLoginSubtitle,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      CustomTextField(
                        label: AppStrings.emailAddress,
                        hint: 'admin@dhs.com',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: AppStrings.password,
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        enabled: !authState.isLoading,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: authState.isLoading 
                                ? null 
                                : (val) => setState(() => _rememberMe = val ?? false),
                              activeColor: context.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.rememberMe,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: authState.isLoading 
                              ? null 
                              : () => _showResetPasswordDialog(context),
                            child: const Text(AppStrings.forgotPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (authState.hasError) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: context.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.colorScheme.error.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: context.colorScheme.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error.toString().replaceFirst('Exception: ', ''),
                                  style: TextStyle(color: context.colorScheme.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      CustomButton(
                        text: AppStrings.loginTitle,
                        onPressed: authState.isLoading ? null : _handleLogin,
                        loading: authState.isLoading,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                
                SizedBox(height: tokens.space32),
                
                Text(
                  'v1.0.0 • Deshmukh Hardware & Steel',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController(text: _emailController.text);
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(AppStrings.resetPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.resetPasswordSubtitle),
              const SizedBox(height: 16),
              CustomTextField(
                label: AppStrings.emailAddress,
                hint: 'admin@dhs.com',
                controller: emailController,
                prefixIcon: Icons.email_outlined,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            CustomButton(
              text: AppStrings.sendLink,
              loading: isResetting,
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.enterValidEmail)),
                  );
                  return;
                }

                setDialogState(() => isResetting = true);
                  try {
                  await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(AppStrings.resetLinkSent),
                        backgroundColor: context.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    String message = e.toString().replaceFirst('Exception: ', '');
                    if (message.contains('XMLHttpRequest')) {
                      message = AppStrings.backendConnectionError;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message), backgroundColor: context.colorScheme.error),
                    );
                  }
                } finally {
                  emailController.dispose();
                  if (context.mounted) {
                    setDialogState(() => isResetting = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(tokens.radiusXl),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.space16),
        Text(
          AppStrings.deshmukhErp,
          style: context.textTheme.headlineMedium?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: context.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
