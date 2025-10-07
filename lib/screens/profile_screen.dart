import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_form_widget.dart';
import 'device_info_screen.dart';
import 'login_screen.dart';

/// Enhanced Profile Screen with comprehensive user profile management
/// Includes profile editing, image picker, and device info access
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _showEditForm = false;

  @override
  void initState() {
    super.initState();
    // Initialize profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 Profile screen initializing...');
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      profileProvider.initializeProfile();
    });
  }

  /// Show image picker options (camera or gallery)
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Profile Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _openCamera();
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build image option widget
  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  /// Open camera specifically
  Future<void> _openCamera() async {
    try {
      debugPrint('📷 Opening camera directly...');

      // Check and request camera permission
      final cameraStatus = await Permission.camera.request();
      debugPrint('📋 Camera permission status: $cameraStatus');

      if (cameraStatus != PermissionStatus.granted) {
        debugPrint('❌ Camera permission denied');
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }

      debugPrint('✅ Camera permission granted, launching camera...');

      // Force camera to open (not gallery)
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        debugPrint('📸 Photo captured: ${photo.path}');
        setState(() {
          _selectedImage = File(photo.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📸 Photo captured successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('❌ Camera was cancelled or failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show permission dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'This app needs camera permission to take photos. Please enable camera permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint('🎥 Attempting to pick image from: ${source.name}');

      // Request camera permission if using camera
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required to take photos'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        debugPrint('📷 Camera permission granted, opening camera...');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false,
      );

      if (pickedFile != null) {
        debugPrint('✅ Image picked successfully: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        if (mounted) {
          String message =
              source == ImageSource.camera
                  ? 'Photo captured successfully!'
                  : 'Image selected from gallery!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
        }
      } else {
        debugPrint('⚠️ No image selected - user cancelled');
        if (mounted) {
          String message =
              source == ImageSource.camera
                  ? 'Camera cancelled'
                  : 'Gallery selection cancelled';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        String errorMessage = 'Error accessing ${source.name}';
        if (source == ImageSource.camera) {
          errorMessage +=
              '. Camera might not be available on this device/emulator.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Navigate to device info screen
  void _navigateToDeviceInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceInfoScreen()),
    );
  }

  /// Handle user logout
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // Clear profile data
    profileProvider.clearProfile();

    // Logout user
    await authProvider.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, profileProvider, authProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(profileProvider, authProvider),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  if (_showEditForm) ...[
                    _buildEditProfileForm(profileProvider),
                    const SizedBox(height: 30),
                  ],
                  _buildMenuOptions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build profile header with avatar and basic info
  Widget _buildProfileHeader(
    ProfileProvider profileProvider,
    AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final userProfile = profileProvider.userProfile;
    final userEmail = authProvider.user?.email ?? 'No email';

    return Column(
      children: [
        // Profile Avatar with edit indicator
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child:
                  _selectedImage == null
                      ? Icon(
                        Icons.person,
                        size: 60,
                        color: theme.colorScheme.primary,
                      )
                      : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _showImagePickerOptions,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // User Name
        Text(
          userProfile?.displayName ?? 'User Name',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          userEmail,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),

        // Profile completion status
        if (userProfile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: userProfile.isComplete ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userProfile.isComplete
                  ? 'Profile Complete'
                  : 'Profile Incomplete',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build action buttons row
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showEditForm = !_showEditForm;
              });
            },
            icon: Icon(_showEditForm ? Icons.close : Icons.edit),
            label: Text(_showEditForm ? 'Cancel Edit' : 'Update Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _navigateToDeviceInfo,
            icon: const Icon(Icons.info),
            label: const Text('Device Info'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Build edit profile form
  Widget _buildEditProfileForm(ProfileProvider profileProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileFormWidget(
              onProfileUpdated: () {
                setState(() {
                  _showEditForm = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build menu options
  Widget _buildMenuOptions() {
    final menuItems = [
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'subtitle': 'Sign out of your account',
        'onTap': _handleLogout,
        'isDestructive': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...menuItems.map(
          (item) => _buildMenuItem(
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            onTap: item['onTap'] as VoidCallback,
            isDestructive: item['isDestructive'] as bool? ?? false,
          ),
        ),
      ],
    );
  }

  /// Build individual menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
