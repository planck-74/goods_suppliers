abstract class OfferState {}

class OfferInitial extends OfferState {}

class OfferLoaded extends OfferState {
  final List<dynamic> offerProducts;

  OfferLoaded(this.offerProducts);
}

class OfferLoading extends OfferState {}

class OfferError extends OfferState {
  final String message;

  OfferError(this.message);
}
