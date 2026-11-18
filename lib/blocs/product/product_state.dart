
import 'package:equatable/equatable.dart';
import 'package:estore_app/models/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductsLoaded extends ProductState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  final Product? product;
  final List<Product> products;

  const ProductOperationSuccess({
    required this.message,
    this.product,
    required this.products,
  });

  @override
  List<Object?> get props => [message, product, products];
}
