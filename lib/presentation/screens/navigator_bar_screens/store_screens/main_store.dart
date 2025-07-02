import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/search_main_store_cubit/search_main_store_cubit.dart';
import 'package:goods/business_logic/cubits/search_products/search_products_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/cards/card_available.dart';
import 'package:goods/presentation/cards/card_offer.dart';
import 'package:goods/presentation/cards/card_unavailable.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/available_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/offer_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/unavailable_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_cubit.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_state.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/available/available_state.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_state.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedTabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: customAppBar(
              context,
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {},
                    child: const Text(
                      'بضاعتك',
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => StoreSearchSheet(
                            selectedTabIndexNotifier: _selectedTabIndex),
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/AddProduct');
                    },
                    icon: const Icon(
                      Icons.add,
                    ),
                  ),
                ],
              )),
          body: Column(
            children: [
              Container(
                height: 35,
                color: Theme.of(context).hoverColor,
                child: TabBar(
                  tabs: const [
                    Tab(text: 'عروض'),
                    Tab(text: 'موجود'),
                    Tab(text: 'غير موجود'),
                  ],
                  onTap: (index) {
                    _selectedTabIndex.value = index;
                  },
                ),
              ),
              const Flexible(
                child: TabBarView(
                  children: [Offer(), Available(), UnAvailable()],
                ),
              ),
            ],
          )),
    );
  }
}

class StoreSearchSheet extends StatefulWidget {
  final ValueNotifier<int> selectedTabIndexNotifier;
  const StoreSearchSheet({super.key, required this.selectedTabIndexNotifier});

  @override
  State<StoreSearchSheet> createState() => StoreSearchSheetState();
}

class StoreSearchSheetState extends State<StoreSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.selectedTabIndexNotifier.value;
    widget.selectedTabIndexNotifier.addListener(_onTabChanged);
    // Trigger initial search when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchMainStoreCubit>().searchProductsByName(
            _searchQuery,
            _currentTabIndex,
            storeId: storeId,
          );
    });
  }

  void _onTabChanged() {
    setState(() {
      _currentTabIndex = widget.selectedTabIndexNotifier.value;
    });
    // Always trigger search on tab change, even if search box is empty
    context.read<SearchMainStoreCubit>().searchProductsByName(
          _searchQuery,
          _currentTabIndex,
          storeId: storeId,
        );
  }

  @override
  void dispose() {
    widget.selectedTabIndexNotifier.removeListener(_onTabChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  print('_currentTabIndex: $_currentTabIndex');
                  context.read<SearchMainStoreCubit>().searchProductsByName(
                        _searchQuery,
                        _currentTabIndex,
                        storeId: storeId,
                      );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<SearchMainStoreCubit, SearchMainStoreState>(
                builder: (context, state) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state is SearchMainStoreLoaded
                          ? state.products.length
                          : 1,
                      itemBuilder: (context, index) {
                        if (state is SearchMainStoreLoaded) {
                          final product = state.products[index];
                          if (_currentTabIndex == 0) {
                            // Offers tab
                            return OfferCard(
                              product: product,
                              storeId: storeId,
                              productData: const [],
                              index: index,
                            );
                          } else if (_currentTabIndex == 1) {
                            // Available tab
                            return AvailableCard(
                              product: product,
                              storeId: storeId,
                              productData: const [],
                              index: index,
                            );
                          } else if (_currentTabIndex == 2) {
                            // Unavailable tab
                            return unAvailableCard(
                              product: product,
                              index: index,
                              productData: const [],
                              context: context,
                            );
                          }
                        }
                        if (state is SearchMainStoreLoading) {
                          return const Column(
                            children: [
                              SizedBox(height: 100),
                              CircularProgressIndicator(),
                            ],
                          );
                        } else if (state is SearchMainStoreError) {
                          return Center(child: Text(state.message));
                        }
                        return const Center(child: Text('لا توجد نتائج للبحث'));
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
