import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/eco_tip.dart';

class EcoTipService {

  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://ecolens-c967b-default-rtdb.europe-west1.firebasedatabase.app/',
  ).ref("eco_tips");

  Stream<List<EcoTip>> getEcoTips() {
    return _db.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      
      final Map<dynamic, dynamic> tipsMap = Map<dynamic, dynamic>.from(data as Map);
      
      final List<EcoTip> tips = [];
      tipsMap.forEach((key, value) {
        tips.add(EcoTip.fromMap(key.toString(), Map<dynamic, dynamic>.from(value as Map)));
      });
      
      // Ordenar por fecha descendente
      tips.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return tips;
    });
  }

  Future<void> addEcoTip(EcoTip tip) async {
    await _db.push().set(tip.toMap());
  }

  Future<void> addLike(EcoTip tip, String username) async {
    if (tip.id != null) {
      
      final bool alreadyLiked = tip.likedBy.containsKey(username);
      
      if (alreadyLiked) {
        //Quitar like
        await _db.child(tip.id!).child('likedBy').child(username).remove();
      } else {
        //Añadir like
        await _db.child(tip.id!).child('likedBy').child(username).set(true);
      }
    }
  }
}
