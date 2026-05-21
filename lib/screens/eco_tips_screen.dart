import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../models/eco_tip.dart';
import '../services/eco_tip_service.dart';
import '../services/user_service.dart';
import '../models/user.dart' as model;
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);


class EcoTipsScreen extends StatefulWidget {
  const EcoTipsScreen({super.key});

  @override
  State<EcoTipsScreen> createState() => _EcoTipsScreenState();
}

class _EcoTipsScreenState extends State<EcoTipsScreen> {

  final EcoTipService ecoTipService = EcoTipService();
  final UserService userService = UserService();
  final TextEditingController tipController = TextEditingController();
  model.User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  //Usuario actual
  Future<void> _loadUser() async {
    final user = await userService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  void _showPostToast() {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text('Tip shared with the community!', style: const TextStyle(fontWeight: FontWeight.bold)),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 600),
      icon: const Icon(Icons.thumb_up_rounded),
      showIcon: true,
      primaryColor: const Color(0xFF86C28B),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      // Margen inferior aumentado para que el toast suba sobre el menú
      margin: const EdgeInsets.only(bottom: 110, left: 12, right: 12),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  //publicar comentario
  void postTip() async {
    logger.d('Posting tip: ${tipController.text}');
    //Si el usuario no está logeaod o no ha escrito nada no se publica
    if (tipController.text.trim().isEmpty || currentUser == null) return;

    logger.d('Posting tip, después del return: ${tipController.text}');

    final newTip = EcoTip(
      username: currentUser!.username,
      text: tipController.text.trim(),
      timestamp: DateTime.now(),
      avatar: currentUser!.avatar,
      likedBy: {},
    );

    try {
      await ecoTipService.addEcoTip(newTip);
      tipController.clear();
      if (mounted) {
        _showPostToast();
      }
    } catch (e) {
      logger.e('Error posting tip: $e');
    }
  }

  //Añadir like
  void postLike(EcoTip tip) async{
    await ecoTipService.addLike(tip, currentUser!.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Eco-Tips',
          style: TextStyle(
            color: Color(0xFF6DA67A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<EcoTip>>(
              stream: ecoTipService.getEcoTips(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tips'));
                }

                final tips = snapshot.data ?? [];
                if (tips.isEmpty) {
                  return const Center(child: Text('No tips yet. Be the first to share one!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    //Mostrar comentario
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //avatar del usuario
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(tip.avatar),
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        tip.username,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6DA67A)),
                                      ),
                                      Text(
                                        '${tip.timestamp.day}/${tip.timestamp.month} ${tip.timestamp.hour}:${tip.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tip.text,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF86C28B),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          minimumSize: Size.zero,
                                        ),
                                        onPressed: () => postLike(tip),
                                        icon: const Icon(Icons.favorite_rounded, size: 18),
                                        label: Text('${tip.likedBy.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tipController,
                    decoration: InputDecoration(
                      hintText: 'Share an eco-tip...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: postTip,
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF6DA67A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
