import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> fetchAndSaveStoreId() async {
  try {
    final String supplierId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(supplierId)
        .get();

    if (supplierSnapshot.exists) {
      final data = supplierSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('storeId')) {
        final storeId = data['storeId'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('storeId', storeId);

      } else {
      }
    } else {
    }
  } catch (e) {
  }
}

Future<String?> getStoreId() async {
  try {
    final String supplierId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(supplierId)
        .get();

    if (supplierSnapshot.exists) {
      final data = supplierSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('storeId')) {
        final String fetchedStoreId = data['storeId'];
        return fetchedStoreId;
      } else {}
    } else {
    }
  } catch (e) {
  }

  return null;
}
