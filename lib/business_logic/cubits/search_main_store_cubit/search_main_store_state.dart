part of 'search_main_store_cubit.dart';

@immutable
sealed class SearchMainStoreState {}

final class SearchMainStoreInitial extends SearchMainStoreState {}

final class SearchMainStoreLoading extends SearchMainStoreState {}

final class SearchMainStoreLoaded extends SearchMainStoreState {
  final List<Map<String, dynamic>> products;

  SearchMainStoreLoaded(this.products);
}

final class SearchMainStoreError extends SearchMainStoreState {
  final String message;

  SearchMainStoreError(this.message);
}
