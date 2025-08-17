import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/get_client_data/get_client_data_state.dart';

class GetClientDataCubit extends Cubit<GetClientDataState> {
  GetClientDataCubit() : super(GetClientDataInitial());
  Map<String, dynamic>? client;

  Future<void> getClientData(String clientId) async {
    try {
      emit(GetClientDataLoading());

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('clients')
              .doc(clientId)
              .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? clientData = documentSnapshot.data();
        client = {
          'name': clientData!['name'],
          'government': clientData['government'],
          'town': clientData['town'],
          'category': clientData['category'],
          'geoLocation': clientData['geoLocation'],
          'phoneNumber': clientData['phoneNumber'],
          'secondPhoneNumber': clientData['secondPhoneNumber'],
          'businessName': clientData['businessName'],
          'imageUrl': clientData['imageUrl'],
        };

        Future.delayed(const Duration(seconds: 3), () {
          emit(GetClientDataSuccess(client!));
        });
      } else {
        emit(GetClientDataError('Client not found'));
      }
    } catch (e) {
      // Emit error state if something goes wrong
      emit(GetClientDataError(e.toString()));
    }
  }

  void fetchChats() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('chats').get();
    print(querySnapshot.docs.length);
  }
}
