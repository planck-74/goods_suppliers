abstract class AvailableState {}

class AvailableInitial extends AvailableState {}

class AvailableLoaded extends AvailableState {
  final List<dynamic> AvailableProducts;

  AvailableLoaded(this.AvailableProducts);
}

class AvailableLoading extends AvailableState {}

class AvailableLoadingMore extends AvailableState {
  final List<dynamic> products;
  AvailableLoadingMore(this.products);
}

class AvailableError extends AvailableState {
  final String message;

  AvailableError(this.message);
}
