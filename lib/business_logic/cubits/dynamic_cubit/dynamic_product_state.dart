import 'package:flutter/material.dart';

@immutable
sealed class DynamicProductState {}

final class DynamicProductInitial extends DynamicProductState {}

final class DynamicProductLoading extends DynamicProductState {}

final class DynamicProductLoaded extends DynamicProductState {}

final class DynamicProductError extends DynamicProductState {
  final String message;

  DynamicProductError(this.message);
}
