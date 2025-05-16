import 'package:meta/meta.dart';

@immutable
abstract class FirestoreState {}

class FirestoreInitial extends FirestoreState {}

class FirestoreLoading extends FirestoreState {}

class FirestoreLoaded extends FirestoreState {
  FirestoreLoaded();
}

class FirestoreError extends FirestoreState {
  FirestoreError();
}
