import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/screens/exercise/work_out.dart';
import 'package:fitbliss/screens/loading.dart/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitbliss/data/models/user_model.dart';
import 'package:fitbliss/screens/onboarding/age.dart';
import 'package:fitbliss/screens/onboarding/weight.dart';
import 'package:fitbliss/screens/onboarding/level.dart';
import 'package:fitbliss/screens/onboarding/goal.dart';
import 'package:fitbliss/main.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? 'Guest');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      await supabase
          .from('profiles')
          .update({
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
          })
          .eq('UID', widget.user!.id);

      setState(() {
        _isEditing = false;
      });
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: const Color(0xffE91E63),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xffE91E63),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar and Basic Info
            _buildUserInfo(),
            const SizedBox(height: 24),

            // Personal Information
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 8),
            _buildPersonalInfoCard(),
            const SizedBox(height: 24),

            // Fitness Preferences
            _buildSectionTitle('Fitness Preferences'),
            const SizedBox(height: 8),
            _buildFitnessPreferencesCard(),
            const SizedBox(height: 24),

            // Settings
            _buildSectionTitle('Settings'),
            const SizedBox(height: 8),
            _buildSettingsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.dmSans().fontFamily,
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Name',
            enabled: _isEditing,
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            enabled: _isEditing,
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone',
            enabled: _isEditing,
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xffE91E63)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildFitnessPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreferenceItem(
            title: 'Fitness Level',
            value: widget.user?.level ?? 'Not set',
            onTap: () {
              Get.to(() => const LevelSelector());
            },
          ),
          const Divider(height: 1),
          _buildPreferenceItem(
            title: 'Fitness Goal',
            value: widget.user?.goal ?? 'Not set',
            onTap: () {
              Get.to(() => const GoalSelector());
            },
          ),
          const Divider(height: 1),
          _buildPreferenceItem(
            title: 'Plan Your Workout',
            value: 'Create a custom workout plan',
            onTap: () {
              Get.to(() => WorkoutPlannerScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xffE91E63),
            child: Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user!.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.user!.age} years • ${widget.user!.weight} • ${widget.user!.level}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Goal: ${widget.user!.goal!.replaceAll("_", " ")}',
                  style: const TextStyle(
                    color: Color(0xffE91E63),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: GoogleFonts.dmSans().fontFamily,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xffE91E63)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            icon: Icons.notifications,
            onTap: () {
              // TODO: Implement notification settings
              Get.snackbar('Info', 'Notification settings coming soon!');
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            icon: Icons.lock,
            onTap: () {
              // TODO: Implement privacy settings
              Get.snackbar('Info', 'Privacy settings coming soon!');
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            icon: Icons.logout,
            onTap: () async {
              await supabase.auth.signOut();
              uidStorage.clearUID();
              Get.offAll(() => LoadingScreen());
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffE91E63)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textColor ?? Colors.black87,
          fontFamily: GoogleFonts.dmSans().fontFamily,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
