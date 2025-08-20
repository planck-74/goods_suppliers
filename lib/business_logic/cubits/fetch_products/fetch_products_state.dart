abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<dynamic> products;

  ProductsLoaded(this.products);
}

class ProductsLoading extends ProductsState {}

class ProductsLoadingMore extends ProductsState {
  final List<dynamic> products;
  ProductsLoadingMore(this.products);
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError(this.message);
}
