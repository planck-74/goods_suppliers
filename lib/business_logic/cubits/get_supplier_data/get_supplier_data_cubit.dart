import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class GetSupplierDataCubit extends Cubit<GetSupplierDataState> {
  Map<String, dynamic>? supplier;

  GetSupplierDataCubit() : super(GetSupplierDataInitial());
  Future<void> getSupplierData() async {
    try {
      emit(GetSupplierDataLoading());

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('suppliers')
              .doc(supplierId)
              .get();

      if (documentSnapshot.exists) {

        Map<String, dynamic>? supplierData = documentSnapshot.data();
        supplier = {
          'businessName': supplierData!['businessName'],
          'imageUrl': supplierData['imageUrl'],
          'town': supplierData['town'],
          'government': supplierData['government'],
          'category': supplierData['category'],
          'phoneNumber': supplierData['phoneNumber'],
          'secondPhoneNumber': supplierData['secondPhoneNumber'],
          'minOrderPrice': supplierData['minOrderPrice'] ?? 3000,
          'minOrderProducts': supplierData['minOrderProducts'] ?? 5,
        };

        emit(GetSupplierDataSuccess([supplier!]));
      } else {

        emit(GetSupplierDataError('Supplier not found'));
      }
    } catch (e) {

      emit(GetSupplierDataError(e.toString()));
    }
  }

  void clearSupplierData() {
    supplier = null;
    emit(GetSupplierDataInitial());
  }
}
