
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/models/product.dart';
import 'package:estore_app/services/product_service.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;

  List<Product> _products = [];

  ProductBloc({
    required this.productService,
  }) : super(const ProductInitial()) {
    on<FetchProduct>(_onFetchProduct);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onFetchProduct(
    FetchProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      _products = await productService.getProducts();

      emit(ProductsLoaded(List.unmodifiable(_products)));
    } catch (e) {
      emit(ProductError('Unable to load products: ${e.toString()}'));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final newProduct = await productService.addProduct(event.product);

      _products = [..._products, newProduct];

      emit(
        ProductOperationSuccess(
          message: 'Product added successfully',
          product: newProduct,
          products: List.unmodifiable(_products),
        ),
      );
    } catch (e) {
      emit(ProductError('Unable to add product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final updatedProduct =
          await productService.updateProduct(event.product);

      _products = _products.map((product) {
        return product.id == updatedProduct.id
            ? updatedProduct
            : product;
      }).toList();

      emit(
        ProductOperationSuccess(
          message: 'Product updated successfully',
          product: updatedProduct,
          products: List.unmodifiable(_products),
        ),
      );
    } catch (e) {
      emit(ProductError('Unable to update product: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      await productService.deleteProduct(event.productId);

      _products = _products
          .where((product) => product.id != event.productId)
          .toList();

      emit(
        ProductOperationSuccess(
          message: 'Product deleted successfully',
          products: List.unmodifiable(_products),
        ),
      );
    } catch (e) {
      emit(ProductError('Unable to delete product: ${e.toString()}'));
    }
  }
}
