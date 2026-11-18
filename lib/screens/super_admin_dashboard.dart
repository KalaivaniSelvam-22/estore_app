
import 'package:estore_app/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/models/product.dart';
import 'package:estore_app/blocs/product/product_bloc.dart';
import 'package:estore_app/blocs/product/product_event.dart';
import 'package:estore_app/blocs/product/product_state.dart';
import 'package:estore_app/screens/product_form_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() =>
      _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  static const Color primaryColor = Color(0xFF5B4BDB);
  static const Color secondaryColor = Color(0xFF9C6ADE);
  static const Color textColor = Color(0xFF292547);

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _stockFilter = 'All';
  String _selectedCategory = 'All Categories';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProductForm(
    BuildContext context, {
    Product? product,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductBloc>(),
          child: ProductFormScreen(product: product),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${product.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final productId = product.id;

      if (productId == null) return;

      context.read<ProductBloc>().add(
            DeleteProduct(productId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Manage your store inventory',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openProductForm(context),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Product listing
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (state is ProductError) {
                return _buildError(context, state.message);
              }

              final List<Product> products;

              if (state is ProductsLoaded) {
                products = state.products;
              } else if (state is ProductOperationSuccess) {
                products = state.products;
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (products.isEmpty) {
                return _buildEmptyState();
              }

              return _buildProductContent(context, products);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductContent(
    BuildContext context,
    List<Product> products,
  ) {
    final categories = products
        .map((product) => product.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final categoryOptions = [
      'All Categories',
      ...categories,
    ];

    final activeCategory =
        categoryOptions.contains(_selectedCategory)
            ? _selectedCategory
            : 'All Categories';

    // Apply search and filters.
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

      return matchesSearch &&
          matchesStock &&
          matchesCategory;
    }).toList();

    // Available products first, while preserving order
    // within each stock group.
    final indexedProducts =
        filteredProducts.asMap().entries.toList();

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
        // Search field
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
              prefixIcon: const Icon(
                Icons.search,
                color: primaryColor,
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Stock and category filters
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
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All'),
                    ),
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

        // Product count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                '${sortedProducts.length} found',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Product grid
        Expanded(
          child: sortedProducts.isEmpty
              ? _buildNoResults()
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async {
                    context.read<ProductBloc>().add(
                          const FetchProduct(),
                        );
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth >= 700 ? 3 : 2;

                      return GridView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          4,
                          12,
                          20,
                        ),
                        itemCount: sortedProducts.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 310,
                        ),
                        itemBuilder: (context, index) {
                          return _buildProductCard(
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
  }

  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 45,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            'No matching products found',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try changing your search or filters.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 45,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load products',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductBloc>().add(
                      const FetchProduct(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: primaryColor,
          ),
          SizedBox(height: 12),
          Text(
            'No products available',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add your first product to get started.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
  ) {
    final inStock = product.stockQuantity > 0;

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: primaryColor.withValues(alpha: 0.10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
              child: ProductImage(
                product: product,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 9),

            // Product name
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
              ),
            ),

            const SizedBox(height: 5),

            // Price
            Text(
              '₹${product.price.toStringAsFixed(2)}',
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
                  size: 14,
                  color: inStock ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 5),
                Text(
                  inStock
                      ? 'Stock: ${product.stockQuantity}'
                      : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: inStock ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Edit and Delete actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _openProductForm(
                          context,
                          product: product,
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 15,
                      ),
                      label: const Text(
                        'Edit',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: primaryColor,
                        side: const BorderSide(
                          color: primaryColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _confirmDelete(context, product);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 15,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.red,
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
