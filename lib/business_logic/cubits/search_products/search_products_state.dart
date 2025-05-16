part of 'search_products_cubit.dart';

@immutable
sealed class SearchProductsState {}

final class SearchProductsInitial extends SearchProductsState {
  final List<Map<String, dynamic>> products;

  SearchProductsInitial({required this.products});
}

final class SearchProductsLoading extends SearchProductsState {}

final class SearchProductsLoaded extends SearchProductsState {
  final List<Map<String, dynamic>> products;

  SearchProductsLoaded(this.products);
}

final class SearchProductsError extends SearchProductsState {
  final String message;

  SearchProductsError(this.message);
}
