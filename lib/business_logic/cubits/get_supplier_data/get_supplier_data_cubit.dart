import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class GetSupplierDataCubit extends Cubit<GetSupplierDataState> {
  Map<String, dynamic>? supplier;

  GetSupplierDataCubit() : super(GetSupplierDataInitial());
  Future<void> getSupplierData() async {
    print(0);
    try {
      emit(GetSupplierDataLoading());

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('suppliers')
              .doc(supplierId)
              .get();
      print(1);

      if (documentSnapshot.exists) {
        print(2);

        // Extracting the specific fields from the document
        Map<String, dynamic>? supplierData = documentSnapshot.data();
        supplier = {
          'businessName': supplierData?['businessName'],
          'imageUrl': supplierData?['imageUrl'],
          'town': supplierData?['town'],
          'government': supplierData?['government'],
          'category': supplierData?['category'],
          'phoneNumber': supplierData?['phoneNumber'],
          'secondPhoneNumber': supplierData?['secondPhoneNumber'],
          'minOrderPrice': supplierData?['minOrderPrice'] ?? 3000,
          'minOrderProducts': supplierData?['minOrderProducts'] ?? 5,
        };

        // Emit success state with the fetched supplier data
        emit(GetSupplierDataSuccess([supplier!]));
      } else {
        print(3);

        // Emit error if the supplier document does not exist
        emit(GetSupplierDataError('Supplier not found'));
      }
    } catch (e) {
      print(4);

      // Emit error state if something goes wrong
      emit(GetSupplierDataError(e.toString()));
    }
  }

  void clearSupplierData() {
    supplier = null;
    emit(GetSupplierDataInitial());
  }
}
