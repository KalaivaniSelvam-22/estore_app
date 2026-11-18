
import 'package:estore_app/blocs/auth/auth_bloc.dart';
import 'package:estore_app/blocs/cart/cart_bloc.dart';
import 'package:estore_app/blocs/product/product_bloc.dart';

import 'package:estore_app/services/api_service.dart';
import 'package:estore_app/services/auth_service.dart';
import 'package:estore_app/services/product_service.dart';

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(),
  );

  getIt.registerLazySingleton<ApiService>(
    () => ApiService(),
  );

  getIt.registerLazySingleton<ProductService>(
    () => ProductService(
      apiService: getIt<ApiService>(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(
      productService: getIt<ProductService>(),
    ),
  );

  getIt.registerFactory<CartBloc>(
    () => CartBloc(),
  );
}
