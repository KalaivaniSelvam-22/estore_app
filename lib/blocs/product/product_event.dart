
import 'package:equatable/equatable.dart';
import 'package:estore_app/models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProduct extends ProductEvent {
  const FetchProduct();
}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final int productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}
