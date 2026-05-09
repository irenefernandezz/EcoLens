import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'package:helloworld/models/user.dart' as model;
import 'package:logger/logger.dart';
import '../shared/logout_dialog.dart';

// Configuración de logger
var logger = Logger(
  printer: PrettyPrinter(),
);


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();
  model.User? currentUser; // Eliminado 'late'

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final user = await userService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  void _changeAvatar(model.User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            children: [
              const Text('Select Avatar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                //Mismo espacio entre los avatares
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _avatarOption(user, 'lib/resources/profile.png'),
                  _avatarOption(user, 'lib/resources/icono_gato.png'),
                  _avatarOption(user, 'lib/resources/icono_mundo.png'),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _avatarOption(model.User user, String path) {
    return GestureDetector(

      //Actualizar el usuario actual con el nuevo avatar
      onTap: () async {
        final updatedUser = model.User(
          id: user.id,
          username: user.username,
          email: user.email,
          password: user.password,
          avatar: path,
        );
        await userService.updateUser(updatedUser);
        _loadName(); // Recargar datos
        if (mounted) Navigator.pop(context);
      },
      child: CircleAvatar(
        radius: 35,
        backgroundColor: const Color(0xFF86C28B),
        child: CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage(path),
        ),
      ),
    );
  }

  //Editar el nombre del usuario
  void _editUsername(String currentUsername) {
    final controller = TextEditingController(text: currentUsername);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(
              Icons.edit,
              color: Color(0xFF6DA67A),
              size: 40,
            ),
            const SizedBox(height: 15),
            const Text(
              'Edit Username',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new username',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF6DA67A), width: 2)),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF86C28B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (currentUser != null) {
                final updatedUser = model.User(
                  id: currentUser!.id,
                  username: controller.text,
                  email: currentUser!.email,
                  password: currentUser!.password,
                  avatar: currentUser!.avatar,
                );

                await userService.updateUser(updatedUser);

                if (mounted) {
                  _loadName();
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialogDeleteAccount(BuildContext context, model.User user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              // Icono de alerta
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 50,
              ),
              const SizedBox(height: 15),
              const Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'This action is permanent and cannot be undone',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop();

                  await userService.deleteUser(currentUser!);

                  //Borrar de firebase
                  await FirebaseAuth.instance.currentUser?.delete();

                  if (mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  logger.d('Error deleting user: $e');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => showLogoutDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Welcome, ${currentUser!.username}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Color(0xFF6DA67A)),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color(0xFF86C28B).withOpacity(0.2),
                  backgroundImage: AssetImage(currentUser!.avatar),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _changeAvatar(currentUser!),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color(0xFF6DA67A), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: _buildUserField(
              'Username',
              currentUser!.username,
              onTap: () => _editUsername(currentUser!.username),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: _buildUserField(
              'Email',
              currentUser!.email,
              isEditable: false,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  _showAlertDialogDeleteAccount(context, currentUser!),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Delete Account',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUserField(String label, String value, {bool isEditable = true, VoidCallback? onTap}) {
    final fieldContent = Container(
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value,
                    style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (isEditable)
            const Icon(Icons.edit, size: 20, color: Color(0xFF6DA67A)),
        ],
      ),
    );

    if (isEditable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: fieldContent,
      );
    }
    return fieldContent;
  }
}
