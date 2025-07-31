import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods/business_logic/cubits/image_picker/image_picker_cubit.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/reports/reports_cubit.dart';
import 'package:goods/business_logic/cubits/search_main_store_cubit/search_main_store_cubit.dart';
import 'package:goods/business_logic/cubits/search_products/search_products_cubit.dart';
import 'package:goods/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';

List<BlocProvider> providers = [
  BlocProvider<SignCubit>(
    create: (context) => SignCubit(),
  ),
  BlocProvider<ControllerCubit>(
    create: (context) => ControllerCubit(),
  ),
  BlocProvider<ImageCubit>(
    create: (context) => ImageCubit(),
  ),
  BlocProvider<UnAvailableCubit>(
    create: (context) => UnAvailableCubit(),
  ),
  BlocProvider<AvailableCubit>(
    create: (context) => AvailableCubit(),
  ),
  BlocProvider<DynamicProductCubit>(
    create: (context) => DynamicProductCubit(),
  ),
  BlocProvider<OfferCubit>(
    create: (context) => OfferCubit(),
  ),
  BlocProvider<GetSupplierDataCubit>(
    create: (context) => GetSupplierDataCubit(),
  ),
  BlocProvider<GetClientDataCubit>(
    create: (context) => GetClientDataCubit(),
  ),
  BlocProvider<OrdersCubit>(
    create: (context) => OrdersCubit(),
  ),
  BlocProvider<SearchProductsCubit>(
    create: (context) => SearchProductsCubit(),
  ),
  BlocProvider<AddProductCubit>(
    create: (context) => AddProductCubit(),
  ),
  BlocProvider<SearchMainStoreCubit>(
    create: (context) => SearchMainStoreCubit(),
  ),  BlocProvider<ReportsCubit>(
    create: (context) => ReportsCubit(),
  ),
];
