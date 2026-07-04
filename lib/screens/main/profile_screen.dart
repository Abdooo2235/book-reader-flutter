import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/providers/preferences_provider.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/app_button.dart';
import 'package:book_reader_app/widgets/common/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile and preferences on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final preferencesProvider = Provider.of<PreferencesProvider>(
        context,
        listen: false,
      );

      if (authProvider.user == null &&
          authProvider.status == AuthStatus.authenticated) {
        authProvider.loadCurrentUser();
      }

      if (authProvider.status == AuthStatus.authenticated) {
        preferencesProvider.loadPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Consumer2<AuthProvider, PreferencesProvider>(
      builder: (context, authProvider, preferencesProvider, _) {
        final userName = authProvider.user?['name']?.toString() ?? 'User';
        final userEmail =
            authProvider.user?['email']?.toString() ?? 'user@example.com';
        final isDarkMode = preferencesProvider.theme == 'dark';

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header with Profile Picture
                Padding(
                  padding: const EdgeInsets.only(
                    top: spacingXLarge + spacingSmall,
                    bottom: spacingLarge + spacingSmall,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 57,
                              backgroundColor: colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: colors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: colors.onPrimary,
                                ),
                                onPressed: () {
                                  UiUtils.showInfoSnackBar(
                                    context,
                                    'Profile picture upload coming soon',
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacingMedium),
                      Text(
                        userName,
                        style: labelLarge.copyWith(color: colors.onSurface),
                      ),
                      const SizedBox(height: spacingSmall / 2),
                      Text(
                        userEmail,
                        style: bodyMedium.copyWith(color: colors.secondaryText),
                      ),
                    ],
                  ),
                ),

                Divider(color: colors.border, thickness: 0.5),

                // Profile Options
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: spacingMedium,
                    vertical: spacingSmall,
                  ),
                  child: Column(
                    children: [
                      _staggerOption(
                        reduceMotion,
                        0,
                        _buildProfileOption(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'Change Name',
                          subtitle: userName,
                          onTap: _showChangeNameDialog,
                        ),
                      ),
                      const SizedBox(height: spacingMedium),
                      _staggerOption(
                        reduceMotion,
                        1,
                        _buildProfileOption(
                          context: context,
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: () {
                            UiUtils.showInfoSnackBar(
                              context,
                              'Change password feature coming soon',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: spacingMedium),
                      _staggerOption(
                        reduceMotion,
                        2,
                        _buildThemeToggle(
                          context: context,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: spacingLarge),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: spacingMedium,
                  ),
                  child: SecondaryButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    color: colors.danger,
                    onPressed: () => _handleLogout(context),
                  ),
                ),

                const SizedBox(height: spacingXLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Fades an option row in (always) and slides it up (motion permitting).
  Widget _staggerOption(bool reduceMotion, int index, Widget child) {
    final animated = child
        .animate(delay: staggerStep * index)
        .fadeIn(duration: animationDurationShort, curve: easeOutStrong);
    if (reduceMotion) return animated;
    return animated.slideY(
      begin: 0.1,
      end: 0,
      duration: animationDurationShort,
      curve: easeOutStrong,
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: IconTile(icon: icon),
        title: Text(title, style: labelSmall.copyWith(color: colors.onSurface)),
        subtitle: Text(
          subtitle,
          style: bodySmall.copyWith(color: colors.secondaryText),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.primary),
      ),
    );
  }

  Widget _buildThemeToggle({
    required BuildContext context,
    required bool isDarkMode,
  }) {
    final colors = AppColors.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: IconTile(
          icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
        ),
        title: Text(
          'Theme Mode',
          style: labelSmall.copyWith(color: colors.onSurface),
        ),
        subtitle: Text(
          isDarkMode ? 'Dark Mode' : 'Light Mode',
          style: bodySmall.copyWith(color: colors.secondaryText),
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) async {
            final preferencesProvider = Provider.of<PreferencesProvider>(
              context,
              listen: false,
            );

            try {
              await preferencesProvider.updatePreferences(
                theme: value ? 'dark' : 'light',
              );

              if (context.mounted) {
                UiUtils.showSuccessSnackBar(
                  context,
                  'Theme updated successfully',
                );
              }
            } catch (e) {
              if (context.mounted) {
                UiUtils.showErrorSnackBar(
                  context,
                  preferencesProvider.errorMessage ?? 'Failed to update theme',
                );
              }
            }
          },
          activeThumbColor: colors.primary,
        ),
      ),
    );
  }

  void _showChangeNameDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final colors = AppColors.of(context);
    final currentName = authProvider.user?['name']?.toString() ?? '';
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        title: Text(
          'Change Name',
          style: displaySmall.copyWith(color: colors.onSurface),
        ),
        content: TextField(
          controller: nameController,
          style: bodyMedium.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: bodyMedium.copyWith(color: colors.secondaryText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
              borderSide: BorderSide(color: colors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                UiUtils.showErrorSnackBar(context, 'Name cannot be empty');
                return;
              }

              Navigator.pop(context);

              // Show loading
              if (context.mounted) {
                UiUtils.showLoadingDialog(context);
              }

              try {
                await authProvider.updateProfile(name: newName);
                if (context.mounted) {
                  UiUtils.closeDialog(context);
                  UiUtils.showSuccessSnackBar(
                    context,
                    'Name updated successfully',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  UiUtils.closeDialog(context);
                  UiUtils.showErrorSnackBar(
                    context,
                    authProvider.errorMessage ?? 'Failed to update name',
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: bodyMedium.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await UiUtils.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      confirmColor: AppColors.of(context).danger,
    );

    if (!confirmed || !context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show loading indicator
    UiUtils.showLoadingDialog(context);

    try {
      await authProvider.logout();

      // Close loading dialog - navigation is handled by auth_provider
      if (context.mounted) UiUtils.closeDialog(context);
    } catch (e) {
      // Close loading dialog if still open - navigation handled by auth_provider
      if (context.mounted) UiUtils.closeDialog(context);
    }
  }
}
