// add_product_state.dart
abstract class AddProductState {}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {
  final Map<String, Map<String, dynamic>> selectedProducts;

  AddProductLoading(this.selectedProducts);
}

class AddProductLoaded extends AddProductState {
  final Map<String, Map<String, dynamic>> selectedProducts;

  AddProductLoaded(this.selectedProducts);
}

class AddProductError extends AddProductState {
  final String message;

  AddProductError(this.message);
}
