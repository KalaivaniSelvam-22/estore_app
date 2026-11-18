import 'package:estore_app/blocs/auth/auth_bloc.dart';
import 'package:estore_app/blocs/auth/auth_event.dart';
import 'package:estore_app/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/models/app_user.dart';
import 'package:estore_app/models/product.dart';

import 'package:estore_app/blocs/product/product_bloc.dart';
import 'package:estore_app/blocs/product/product_event.dart';
import 'package:estore_app/blocs/product/product_state.dart';

import 'package:estore_app/blocs/cart/cart_bloc.dart';
import 'package:estore_app/blocs/cart/cart_event.dart';
import 'package:estore_app/blocs/cart/cart_state.dart';

import 'package:estore_app/core/di/injection.dart';
import 'package:estore_app/screens/cart_screen.dart';
import 'package:estore_app/screens/super_admin_dashboard.dart';

class RoleHomeScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const RoleHomeScreen({super.key, required this.user, required this.onLogout});

  static const Color primaryColor = Color(0xFF5B4BDB);
  static const Color secondaryColor = Color(0xFF9C6ADE);
  static const Color backgroundColor = Color(0xFFF1EEFF);
  static const Color textColor = Color(0xFF292547);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProductBloc>()..add(const FetchProduct()),
        ),
        BlocProvider(create: (_) => getIt<CartBloc>()),
      ],
      child: Builder(
        builder: (context) {
          return _DoubleBackToExit(
            child: Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                title: const Text(
                  'E-Store',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                actions: [
                  if (user.isAdmin)
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        final count = state is CartLoaded
                            ? state.totalItems
                            : 0;

                        return IconButton(
                          tooltip: 'My Cart',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CartBloc>(),
                                  child: const CartScreen(),
                                ),
                              ),
                            );
                          },
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 26,
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 19,
                                      minHeight: 19,
                                    ),
                                    child: Text(
                                      '$count',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  IconButton(
                    onPressed: () => _confirmLogout(context),
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              body: SafeArea(
                top: false,
                child: BlocListener<ProductBloc, ProductState>(
                  listener: (context, state) {
                    if (state is ProductsLoaded) {
                      context.read<CartBloc>().add(
                        SyncCartProducts(state.products),
                      );
                    }

                    if (state is ProductOperationSuccess) {
                      context.read<CartBloc>().add(
                        SyncCartProducts(state.products),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),

                      if (!user.isAdmin)
                        const Expanded(child: SuperAdminDashboard())
                      else
                        Expanded(child: _buildAdminProductList()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Compact welcome section
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7667E8), Color(0xFF9C6ADE)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome, ${user.userName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.isAdmin ? 'Admin' : 'Super Admin',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              user.isAdmin
                  ? Icons.shopping_bag_outlined
                  : Icons.dashboard_customize_outlined,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // Admin product listing
  Widget _buildAdminProductList() {
    return _AdminProductList(
      itemBuilder: _buildProductCard,
      errorBuilder: _buildErrorView,
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load products',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductBloc>().add(const FetchProduct());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Logout confirmation
  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  // Individual product card
  Widget _buildProductCard(BuildContext context, Product product) {
    final inStock = product.stockQuantity > 0;

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: primaryColor.withValues(alpha: 0.10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 105,
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: ProductImage(product: product, fit: BoxFit.contain),
            ),

            const SizedBox(height: 8),

            // Product name
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textColor,
              ),
            ),

            const SizedBox(height: 5),

            // Category
            Text(
              product.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            // Price
            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 5),

            // Stock
            Row(
              children: [
                Icon(
                  inStock
                      ? Icons.inventory_2_outlined
                      : Icons.warning_amber_rounded,
                  size: 13,
                  color: inStock ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  inStock ? 'Stock: ${product.stockQuantity}' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: inStock ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Cart quantity and actions
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final matchingItems = cartState is CartLoaded
                    ? cartState.items
                          .where((item) => item.product.id == product.id)
                          .toList()
                    : [];

                final quantity = matchingItems.isNotEmpty
                    ? matchingItems.first.quantity
                    : 0;

                final limitReached = quantity >= product.stockQuantity;

                if (quantity == 0) {
                  return SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: !inStock || product.id == null
                          ? null
                          : () {
                              context.read<CartBloc>().add(AddToCart(product));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        inStock ? 'Add to Cart' : 'Out of Stock',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: () {
                            context.read<CartBloc>().add(
                              UpdateCartQuantity(
                                productId: product.id!,
                                quantity: quantity - 1,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: primaryColor,
                            size: 21,
                          ),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: limitReached
                              ? null
                              : () {
                                  context.read<CartBloc>().add(
                                    AddToCart(product),
                                  );
                                },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: limitReached ? Colors.grey : primaryColor,
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<CartBloc>(),
                                child: const CartScreen(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Go to Cart',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Double-back-to-exit handler
class _DoubleBackToExit extends StatefulWidget {
  final Widget child;

  const _DoubleBackToExit({required this.child});

  @override
  State<_DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<_DoubleBackToExit> {
  DateTime? _lastBackPressed;

  void _handleBackPress() {
    final now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: widget.child,
    );
  }
}

class _AdminProductList extends StatefulWidget {
  final Widget Function(BuildContext, Product) itemBuilder;
  final Widget Function(BuildContext, String) errorBuilder;

  const _AdminProductList({
    required this.itemBuilder,
    required this.errorBuilder,
  });

  @override
  State<_AdminProductList> createState() => _AdminProductListState();
}

class _AdminProductListState extends State<_AdminProductList> {
  static const Color primaryColor = Color(0xFF5B4BDB);
  static const Color textColor = Color(0xFF292547);

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _stockFilter = 'All';
  String _selectedCategory = 'All Categories';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (state is ProductError) {
          return widget.errorBuilder(context, state.message);
        }

        final List<Product> products;

        if (state is ProductsLoaded) {
          products = state.products;
        } else if (state is ProductOperationSuccess) {
          products = state.products;
        } else {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products available',
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          );
        }

        final categories =
            products
                .map((product) => product.category)
                .where((category) => category.trim().isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        final categoryOptions = ['All Categories', ...categories];

        final activeCategory = categoryOptions.contains(_selectedCategory)
            ? _selectedCategory
            : 'All Categories';

        final filteredProducts = products.where((product) {
          final query = _searchQuery.trim().toLowerCase();

          final matchesSearch =
              product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);

          final matchesStock = switch (_stockFilter) {
            'In Stock' => product.stockQuantity > 0,
            'Out of Stock' => product.stockQuantity <= 0,
            _ => true,
          };

          final matchesCategory =
              activeCategory == 'All Categories' ||
              product.category == activeCategory;

          return matchesSearch && matchesStock && matchesCategory;
        }).toList();

        // Keep available products first while preserving
        // the original order within each stock group.
        final indexedProducts = filteredProducts.asMap().entries.toList();

        indexedProducts.sort((a, b) {
          final aAvailable = a.value.stockQuantity > 0;
          final bAvailable = b.value.stockQuantity > 0;

          if (aAvailable == bAvailable) {
            return a.key.compareTo(b.key);
          }

          return aAvailable ? -1 : 1;
        });

        final sortedProducts = indexedProducts
            .map((entry) => entry.value)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 7, 16, 8),
              child: Text(
                'Available Products',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _stockFilter,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(
                          value: 'In Stock',
                          child: Text('In Stock'),
                        ),
                        DropdownMenuItem(
                          value: 'Out of Stock',
                          child: Text('Out of Stock'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _stockFilter = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: activeCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categoryOptions.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                '${sortedProducts.length} products found',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Expanded(
              child: sortedProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 45, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'No matching products found',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: () async {
                        context.read<ProductBloc>().add(const FetchProduct());
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 700 ? 3 : 2;

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                            itemCount: sortedProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 330,
                                ),
                            itemBuilder: (context, index) {
                              return widget.itemBuilder(
                                context,
                                sortedProducts[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
