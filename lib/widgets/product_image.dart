
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:estore_app/models/product.dart';

class ProductImage extends StatelessWidget {
  final Product product;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    final localPath = product.localImagePath;

    if (localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      imageProvider = FileImage(File(localPath));
    } else if (product.image.trim().isNotEmpty) {
      imageProvider = NetworkImage(product.image);
    }

    if (imageProvider == null) {
      return _buildPlaceholder();
    }

    return Image(
      image: imageProvider,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return _buildLoading();
      },
      errorBuilder: (_, _, _) => _buildPlaceholder(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF5B4BDB),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 35,
        color: Colors.grey,
      ),
    );
  }
}
