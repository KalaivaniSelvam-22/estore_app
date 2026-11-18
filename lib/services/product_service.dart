
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:estore_app/core/errors/api_exception.dart';
import 'package:estore_app/models/product.dart';
import 'package:estore_app/services/api_service.dart';

class ProductService {
  final ApiService apiService;

  static const String _storageKey = 'estore_products';

  ProductService({required this.apiService});

  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null) {
        return _decodeProducts(savedData);
      }

      final data = await apiService.get('/products');

      if (data is! List) {
        throw const ApiException('Invalid product response.');
      }

      final products = data.map((item) {
        if (item is! Map) {
          throw const ApiException('Invalid product data.');
        }

        return Product.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      await _saveProducts(products);

      return products;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      await apiService.post(
        '/products',
        data: product.toApiJson(),
      );

      final products = await _readLocalProducts();

      final nextId = products.isEmpty
          ? 1
          : products
                  .map((item) => item.id ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      final newProduct = product.copyWith(id: nextId);

      products.add(newProduct);

      await _saveProducts(products);

      return newProduct;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        throw const ApiException('Product ID is required.');
      }

      await apiService.put(
        '/products/${product.id}',
        data: product.toApiJson(),
      );

      final products = await _readLocalProducts();

      final index = products.indexWhere(
        (item) => item.id == product.id,
      );

      if (index == -1) {
        throw const ApiException('Product not found.');
      }

      products[index] = product;

      await _saveProducts(products);

      return product;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await apiService.delete('/products/$productId');

      final products = await _readLocalProducts();

      products.removeWhere(
        (item) => item.id == productId,
      );

      await _saveProducts(products);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  Future<List<Product>> _readLocalProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData == null) {
      throw const ApiException(
        'Product catalogue not initialized.',
      );
    }

    return _decodeProducts(savedData);
  }

  List<Product> _decodeProducts(String data) {
    final decoded = jsonDecode(data) as List<dynamic>;

    return decoded.map((item) {
      return Product.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<void> _saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      products.map((item) => item.toStorageJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }
}
