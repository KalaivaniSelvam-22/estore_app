
import 'package:equatable/equatable.dart';
import 'package:estore_app/models/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final Product product;

  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final int productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartQuantity extends CartEvent {
  final int productId;
  final int quantity;

  const UpdateCartQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class SyncCartProducts extends CartEvent {
  final List<Product> products;

  const SyncCartProducts(this.products);

  @override
  List<Object?> get props => [products];
}
