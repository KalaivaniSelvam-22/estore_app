
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final String? localImagePath;
  final double rating;
  final int ratingCount;
  final int stockQuantity;

  const Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.localImagePath,
    this.rating = 0,
    this.ratingCount = 0,
    this.stockQuantity = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'];

    return Product(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      localImagePath: json['localImagePath']?.toString(),
      rating: ratingData is Map
          ? (ratingData['rate'] as num?)?.toDouble() ?? 0
          : 0,
      ratingCount: ratingData is Map
          ? (ratingData['count'] as num?)?.toInt() ?? 0
          : 0,
      stockQuantity:
          (json['stockQuantity'] as num?)?.toInt() ?? 10,
    );
  }

  // Data sent to Fake Store API.
  // Local image paths and stock are not sent to the API.
  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
    };
  }

  // Data stored locally, including inventory and uploaded images.
  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'localImagePath': localImagePath,
      'rating': {
        'rate': rating,
        'count': ratingCount,
      },
      'stockQuantity': stockQuantity,
    };
  }

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    String? localImagePath,
    double? rating,
    int? ratingCount,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      localImagePath: localImagePath ?? this.localImagePath,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        description,
        category,
        image,
        localImagePath,
        rating,
        ratingCount,
        stockQuantity,
      ];
}
