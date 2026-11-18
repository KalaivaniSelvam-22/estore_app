
import 'package:equatable/equatable.dart';
import 'package:estore_app/models/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded(this.items);

  double get totalPrice =>
      items.fold(0, (total, item) => total + item.totalPrice);

  int get totalItems =>
      items.fold(0, (total, item) => total + item.quantity);

  @override
  List<Object?> get props => [items];
}
