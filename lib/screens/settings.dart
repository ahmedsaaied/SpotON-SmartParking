// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spoton_app/screens/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final box = GetStorage();
  bool isNotificationsEnabled = true;
  bool isDarkMode = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    final storedTheme = box.read('isDarkMode');
    if (storedTheme != null) {
      isDarkMode = storedTheme;
    } else {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
      box.write('isDarkMode', isDarkMode);
    }
  }

  Future<void> _toggleNotifications(bool enable) async {
    if (enable) {
      final permissionStatus = await Permission.notification.request();
      if (permissionStatus.isGranted) {
        await FirebaseMessaging.instance.subscribeToTopic('general');
      } else {
        setState(() => isNotificationsEnabled = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Notifications permission denied")),
          );
        }
      }
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('general');
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 40, 150, 40),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: isDark
                          ? const Color.fromARGB(255, 22, 22, 22)
                          : Color(0xFFC4C4C4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Theme.of(context).colorScheme.brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: Text(
                            'OFF',
                            style: GoogleFonts.righteous(
                              color: Theme.of(context).colorScheme.brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Spot',
                            style: GoogleFonts.righteous(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 145),
                  _sectionTitle('Account'),
                  const SizedBox(height: 5),
                  _buildAccountInfo(),
                  const SizedBox(height: 20),
                  _sectionTitle('Settings'),
                  const SizedBox(height: 5),
                  _buildSettingsSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    final name = _currentUser?.displayName ?? 'Guest User';
    final email = _currentUser?.email ?? 'No email available';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.saira(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: GoogleFonts.sniglet(
                      color: Theme.of(context).hintColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.edit, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            trailing: Switch(
              value: isNotificationsEnabled,
              onChanged: (value) async {
                setState(() => isNotificationsEnabled = value);
                await _toggleNotifications(value);
              },
              activeColor: Colors.green,
            ),
          ),
          _buildSettingTile(
            icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                isDarkMode = value;
                Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                box.write('isDarkMode', value);
              },
              activeColor: Colors.white,
            ),
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: 'Change Language',
            onTap: () {}, // Implement later
          ),
          _buildSettingTile(
            icon: Icons.description,
            title: 'Terms & Conditions',
            onTap: () {}, // Implement later
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {}, // Implement later
          ),
          _buildSettingTile(
            icon: Icons.mail_outline,
            title: 'Contact Support',
            onTap: () {}, // Implement later
          ),
          _buildSettingTile(
            icon: Icons.reviews,
            title: 'Feedback',
            onTap: () {}, // Implement later
          ),
          _buildSettingTile(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(
        title,
        style: GoogleFonts.saira(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.saira(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
