import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
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
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 30),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 57,
                              backgroundColor: primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: primaryColor,
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
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: whiteColor, width: 2),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Profile picture upload coming soon',
                                        style: bodyMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: labelLarge.copyWith(color: blackColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: bodyMedium.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Divider(
                  color: primaryColor.withValues(alpha: 0.2),
                  thickness: 0.5,
                ),

                // Profile Options
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Change Name
                      _buildProfileOption(
                        icon: Icons.person_outline,
                        title: 'Change Name',
                        subtitle: userName,
                        onTap: () {
                          // TODO: Show dialog to change name
                          _showChangeNameDialog();
                        },
                      ),
                      const SizedBox(height: 12),

                      // Change Password
                      _buildProfileOption(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Change password feature coming soon',
                                style: bodyMedium.copyWith(color: Colors.white),
                              ),
                              backgroundColor: primaryColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Light/Dark Mode
                      Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: primaryColor,
                            ),
                          ),
                          title: Text(
                            'Theme Mode',
                            style: labelSmall.copyWith(color: blackColor),
                          ),
                          subtitle: Text(
                            isDarkMode ? 'Dark Mode' : 'Light Mode',
                            style: bodySmall.copyWith(color: Colors.grey[600]),
                          ),
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (value) async {
                              final preferencesProvider =
                                  Provider.of<PreferencesProvider>(
                                    context,
                                    listen: false,
                                  );

                              try {
                                await preferencesProvider.updatePreferences(
                                  theme: value ? 'dark' : 'light',
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Theme updated successfully',
                                              style: bodyMedium.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: greenColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              preferencesProvider
                                                      .errorMessage ??
                                                  'Failed to update theme',
                                              style: bodyMedium.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: redColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              }
                            },
                            activeThumbColor: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: redColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: labelMedium.copyWith(color: redColor),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          title: Text(title, style: labelSmall.copyWith(color: blackColor)),
          subtitle: Text(
            subtitle,
            style: bodySmall.copyWith(color: Colors.grey[600]),
          ),
          trailing: Icon(Icons.chevron_right, color: primaryColor),
        ),
      ),
    );
  }

  void _showChangeNameDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentName = authProvider.user?['name']?.toString() ?? '';
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Name',
          style: labelMedium.copyWith(color: blackColor),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: bodyMedium.copyWith(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          style: bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Name cannot be empty',
                      style: bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: redColor,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Show loading
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
              }

              try {
                await authProvider.updateProfile(name: newName);
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Name updated successfully',
                              style: bodyMedium.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: greenColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context); // Close loading
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage ??
                                  'Failed to update name',
                              style: bodyMedium.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: redColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: bodyMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: labelMedium.copyWith(color: blackColor)),
        content: Text('Are you sure you want to logout?', style: bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              // Show loading indicator
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
              }

              try {
                await authProvider.logout();

                // Close loading dialog - navigation is handled by auth_provider
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // Close loading dialog if still open - navigation is handled by auth_provider
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Logout',
              style: bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
