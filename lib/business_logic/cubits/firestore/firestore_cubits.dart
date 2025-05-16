import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/firestore/firestore_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> saveSupplier(ClientModel client) async {
    emit(FirestoreLoading());
    try {
      await db.collection('supplier').doc(supplierId).set(client.toMap());
      emit(FirestoreLoaded());
    } catch (e) {
      emit(FirestoreError());
    }
  }
}
