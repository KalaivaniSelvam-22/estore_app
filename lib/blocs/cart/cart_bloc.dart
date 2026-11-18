
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/models/cart_item.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final List<CartItem> _items = [];

  CartBloc() : super(const CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
    on<SyncCartProducts>(_onSyncCartProducts);
  }

  void _onAddToCart(
    AddToCart event,
    Emitter<CartState> emit,
  ) {
    final product = event.product;

    // Products without an ID or available stock cannot be added.
    if (product.id == null || product.stockQuantity <= 0) {
      return;
    }

    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index != -1) {
      final existingItem = _items[index];

      // Prevent cart quantity from exceeding available stock.
      if (existingItem.quantity >= product.stockQuantity) {
        return;
      }

      _items[index] = existingItem.copyWith(
        product: product,
        quantity: existingItem.quantity + 1,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }

    _emitCart(emit);
  }

  void _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) {
    _items.removeWhere(
      (item) => item.product.id == event.productId,
    );

    _emitCart(emit);
  }

  void _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) {
    final index = _items.indexWhere(
      (item) => item.product.id == event.productId,
    );

    if (index == -1) return;

    if (event.quantity <= 0) {
      _items.removeAt(index);
    } else {
      final item = _items[index];

      final quantity = event.quantity
          .clamp(0, item.product.stockQuantity)
          .toInt();

      if (quantity == 0) {
        _items.removeAt(index);
      } else {
        _items[index] = item.copyWith(
          quantity: quantity,
        );
      }
    }

    _emitCart(emit);
  }

  void _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) {
    _items.clear();
    _emitCart(emit);
  }

  void _onSyncCartProducts(
    SyncCartProducts event,
    Emitter<CartState> emit,
  ) {
    final productMap = {
      for (final product in event.products)
        if (product.id != null) product.id!: product,
    };

    final updatedItems = <CartItem>[];

    for (final item in _items) {
      final product = productMap[item.product.id];

      // Remove products that were deleted or have no stock.
      if (product == null || product.stockQuantity <= 0) {
        continue;
      }

      // Keep existing cart quantity within the latest stock limit.
      final quantity = item.quantity
          .clamp(1, product.stockQuantity)
          .toInt();

      updatedItems.add(
        CartItem(
          product: product,
          quantity: quantity,
        ),
      );
    }

    _items
      ..clear()
      ..addAll(updatedItems);

    _emitCart(emit);
  }

  void _emitCart(Emitter<CartState> emit) {
    emit(CartLoaded(List.unmodifiable(_items)));
  }
}
