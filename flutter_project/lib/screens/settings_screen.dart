// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../data/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'رجوع',
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildHeader(),
          _buildAppearanceSection(context),
          _buildInfoSection(),
          _buildLogoutSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue.shade50),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 30,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات التطبيق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تخصيص تجربتك في التطبيق',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Text(
                  'المظهر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.light_mode_outlined,
                          color: currentMode == ThemeMode.light
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        title: Text(
                          'فاتح',
                          style: TextStyle(
                            fontWeight: currentMode == ThemeMode.light
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: currentMode == ThemeMode.light
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () => themeNotifier.value = ThemeMode.light,
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.dark_mode_outlined,
                          color: currentMode == ThemeMode.dark
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        title: Text(
                          'داكن',
                          style: TextStyle(
                            fontWeight: currentMode == ThemeMode.dark
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: currentMode == ThemeMode.dark
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () => themeNotifier.value = ThemeMode.dark,
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.brightness_auto_outlined,
                          color: currentMode == ThemeMode.system
                              ? Colors.purple
                              : Colors.grey,
                        ),
                        title: Text(
                          'تلقائي',
                          style: TextStyle(
                            fontWeight: currentMode == ThemeMode.system
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: currentMode == ThemeMode.system
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () => themeNotifier.value = ThemeMode.system,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Text(
                  'معلومات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'المساعدة والدعم',
              subtitle: 'الأسئلة الشائعة والدعم الفني',
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ),
            const Divider(),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'شروط الخدمة',
              subtitle: 'اطلع على الشروط والأحكام',
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ),
            const Divider(),
            _buildSettingItem(
              icon: Icons.shield_outlined,
              title: 'سياسة الخصوصية',
              subtitle: 'كيف نتعامل مع بياناتك',
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue.shade700),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: () {},
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout_outlined),
        label: const Text('تسجيل الخروج'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.red.shade200),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
