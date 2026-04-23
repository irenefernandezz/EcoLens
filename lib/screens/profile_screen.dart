import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'package:helloworld/models/user.dart' as model;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();

  void _changeAvatar(model.User currentUser) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            children: [
              const Text('Select Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _avatarOption(currentUser, 'lib/resources/profile.png'),
                  _avatarOption(currentUser, 'lib/resources/icono_gato.png'),
                  _avatarOption(currentUser, 'lib/resources/icono_mundo.png'),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _avatarOption(model.User currentUser, String path) {
    return GestureDetector(
      onTap: () async {
        final updatedUser = model.User(
          id: currentUser.id,
          username: currentUser.username,
          email: currentUser.email,
          password: currentUser.password,
          avatar: path,
        );
        await userService.updateUser(updatedUser);
        setState(() {});
        if (mounted) Navigator.pop(context);
      },
      child: CircleAvatar(
        radius: 35,
        backgroundColor: currentUser.avatar == path ? const Color(0xFF86C28B) : Colors.grey[200],
        child: CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage(path),
        ),
      ),
    );
  }

  void _editField(String label, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new $label'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final currentUser = userService.getCurrentUser();
              if (currentUser != null) {
                final updatedUser = model.User(
                  id: currentUser.id,
                  username: label == 'Username' ? controller.text : currentUser.username,
                  email: label == 'Email' ? controller.text : currentUser.email,
                  password: currentUser.password,
                  avatar: currentUser.avatar,
                );
                
                await userService.updateUser(updatedUser);
                
                // Actualizar Email en Firebase si se cambió
                if (label == 'Email') {
                  try {
                    await FirebaseAuth.instance.currentUser?.updateEmail(controller.text);
                  } catch (e) {
                    debugPrint('Error updating email in Firebase: $e');
                  }
                }

                if (mounted) {
                  setState(() {});
                  Navigator.of(context, rootNavigator: true).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = userService.getCurrentUser();

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Welcome, ${currentUser.username}!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
            ),
            const SizedBox(height: 30),
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color(0xFF86C28B).withOpacity(0.2),
                  backgroundImage: AssetImage(currentUser.avatar),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _changeAvatar(currentUser),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF6DA67A), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildUserField('Username', currentUser.username),
            const SizedBox(height: 15),
            _buildUserField('Email', currentUser.email),
            const SizedBox(height: 60),
            TextButton.icon(
              onPressed: () async {
                try {
                  await userService.deleteUser(currentUser);
                  await FirebaseAuth.instance.currentUser?.delete();
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Re-authentication required to delete account')),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserField(String label, String value) {
    return GestureDetector(
      onTap: () => _editField(label, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const Icon(Icons.edit, size: 20, color: Color(0xFF6DA67A)),
          ],
        ),
      ),
    );
  }
}
