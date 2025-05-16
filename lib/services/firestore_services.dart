import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class FirestoreService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String?> getStoreId() async {
    // final supplierId = supplierId;
    try {
      CollectionReference suppliersCollection =
          FirebaseFirestore.instance.collection('suppliers');

      DocumentSnapshot supplierDoc =
          await suppliersCollection.doc(supplierId).get();

      if (supplierDoc.exists) {
        String storeId = supplierDoc['storeId'];

        return storeId;
      } else {}
    } catch (e) {}
    return null;
  }
}
