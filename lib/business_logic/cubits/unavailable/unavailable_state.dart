abstract class UnAvailableState {}

class UnavailableInitial extends UnAvailableState {}

class UnavailableLoaded extends UnAvailableState {
  final List<dynamic> unAvailableProducts;

  UnavailableLoaded(this.unAvailableProducts);
}

class UnavailableLoading extends UnAvailableState {}

class UnavailableLoadingMore extends UnAvailableState {
  final List<dynamic> products;
  UnavailableLoadingMore(this.products);
}

class UnavailableError extends UnAvailableState {
  final String message;

  UnavailableError(this.message);
}
