
import 'package:estore_app/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/blocs/cart/cart_bloc.dart';
import 'package:estore_app/blocs/cart/cart_event.dart';
import 'package:estore_app/blocs/cart/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color primaryColor = Color(0xFF5B4BDB);
  static const Color secondaryColor = Color(0xFF9C6ADE);
  static const Color backgroundColor = Color(0xFFF6F5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(top: false,
        child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded || state.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final product = item.product;

                    final stockLimitReached =
                        item.quantity >= product.stockQuantity;

                    return Card(
                      elevation: 3,
                      shadowColor:
                          primaryColor.withValues(alpha: 0.12),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 85,
                              height: 95,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EDFF),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: ProductImage(
                                     product: product,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF292547),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Available stock: ${product.stockQuantity}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: stockLimitReached
                                          ? Colors.orange.shade800
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EDFF),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _quantityButton(
                                          icon: Icons.remove,
                                          onPressed: () {
                                            context
                                                .read<CartBloc>()
                                                .add(
                                                  UpdateCartQuantity(
                                                    productId:
                                                        product.id!,
                                                    quantity:
                                                        item.quantity - 1,
                                                  ),
                                                );
                                          },
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _quantityButton(
                                          icon: Icons.add,
                                          enabled:
                                              !stockLimitReached,
                                          onPressed: () {
                                            context
                                                .read<CartBloc>()
                                                .add(
                                                  UpdateCartQuantity(
                                                    productId:
                                                        product.id!,
                                                    quantity:
                                                        item.quantity + 1,
                                                  ),
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF292547),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                IconButton(
                                  tooltip: 'Remove item',
                                  onPressed: () {
                                    context
                                        .read<CartBloc>()
                                        .add(
                                          RemoveFromCart(
                                            product.id!,
                                          ),
                                        );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCartSummary(context, state),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE8E2FF),
                    Color(0xFFF3E5FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(85),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 85,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your Cart is Empty!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292547),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      icon: Icon(
        icon,
        size: 18,
        color: enabled ? primaryColor : Colors.grey,
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartLoaded state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.10),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Items',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${state.totalItems}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${state.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<CartBloc>().add(const ClearCart());
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(
                  color: Colors.redAccent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
