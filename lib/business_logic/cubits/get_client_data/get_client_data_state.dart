import 'package:meta/meta.dart';

@immutable
abstract class GetClientDataState {}

class GetClientDataInitial extends GetClientDataState {}

class GetClientDataLoading extends GetClientDataState {}

class GetClientDataSuccess extends GetClientDataState {
  final Map<String, dynamic> client;

  GetClientDataSuccess(this.client);
}

class GetClientDataError extends GetClientDataState {
  final String message;

  GetClientDataError(this.message);
}
