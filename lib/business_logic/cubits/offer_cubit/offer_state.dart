abstract class OfferState {}

class OfferInitial extends OfferState {}

class OfferLoaded extends OfferState {
  final List<dynamic> offerProducts;
  final DateTime timestamp; // ✅ إضافة timestamp للتحديث التلقائي

  OfferLoaded(this.offerProducts) : timestamp = DateTime.now();
}

class OfferLoading extends OfferState {}

class OfferError extends OfferState {
  final String message;

  OfferError(this.message);
}