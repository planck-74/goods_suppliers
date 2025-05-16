part of 'sign_cubit.dart';

sealed class SignState {}

final class SignInitial extends SignState {}

final class SignLoading extends SignState {}

final class SignLoaded extends SignState {}

final class SignFailure extends SignState {}
