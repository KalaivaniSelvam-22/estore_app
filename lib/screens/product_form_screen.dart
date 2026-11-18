
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:estore_app/models/product.dart';
import 'package:estore_app/blocs/product/product_bloc.dart';
import 'package:estore_app/blocs/product/product_event.dart';
import 'package:estore_app/blocs/product/product_state.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;

  static const Color primaryColor = Color(0xFF5B4BDB);
  static const Color textColor = Color(0xFF292547);
  static const Color backgroundColor = Color(0xFFF1EEFF);
  static const Color borderColor = Color(0xFFE5E1F2);

  final List<String> _categories = [
    'electronics',
    'jewelery',
    "men's clothing",
    "women's clothing",
  ];

  late String _selectedCategory;

  String? _localImagePath;
  bool _isPickingImage = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _titleController = TextEditingController(
      text: product?.title ?? '',
    );

    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    _stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '10',
    );

    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    _imageController = TextEditingController(
      text: product?.image ?? '',
    );

    _localImagePath = product?.localImagePath;

    _selectedCategory = product?.category ?? _categories.first;

    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }


Future<void> _pickImage() async {
  try {
    setState(() {
      _isPickingImage = true;
    });

    final selectedFile = await FilePicker.pickFile(
      type: FileType.image,
    );

    // User cancelled file selection.
    if (selectedFile == null) {
      return;
    }

    final selectedPath = selectedFile.path;

    if (selectedPath == null || selectedPath.isEmpty) {
      throw Exception('Unable to access the selected image.');
    }

    final sourceFile = File(selectedPath);

    if (!await sourceFile.exists()) {
      throw Exception('Selected image file was not found.');
    }

    final appDirectory = await getApplicationDocumentsDirectory();

    final imageDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}product_images',
    );

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final extension = selectedFile.extension ?? 'jpg';

    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}.$extension';

    final destinationPath =
        '${imageDirectory.path}${Platform.pathSeparator}$fileName';

    final savedFile = await sourceFile.copy(destinationPath);

    if (!mounted) return;

    setState(() {
      _localImagePath = savedFile.path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image selected successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to select image: $error'),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isPickingImage = false;
      });
    }
  }
}

  void _removeUploadedImage() {
    setState(() {
      _localImagePath = null;
    });
  }

  String? _validateImage(String? value) {
    if (_localImagePath != null &&
        _localImagePath!.trim().isNotEmpty &&
        File(_localImagePath!).existsSync()) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Upload an image or enter an image URL';
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null ||
        !uri.hasScheme ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return 'Enter a valid image URL';
    }

    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock quantity is required';
    }

    final stock = int.tryParse(value.trim());

    if (stock == null || stock < 0) {
      return 'Enter a valid quantity (0 or more)';
    }

    return null;
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existingProduct = widget.product;

    final product = Product(
      id: existingProduct?.id,
      title: _titleController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      image: _imageController.text.trim(),
      localImagePath: _localImagePath,
      rating: existingProduct?.rating ?? 0,
      ratingCount: existingProduct?.ratingCount ?? 0,
      stockQuantity: int.parse(_stockController.text.trim()),
    );

    final bloc = context.read<ProductBloc>();

    if (isEditing) {
      bloc.add(UpdateProduct(product));
    } else {
      bloc.add(AddProduct(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
  if (state is ProductOperationSuccess) {
    Navigator.pop(context, true);
  }

  if (state is ProductError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
},
      builder: (context, state) {
        final isLoading = state is ProductLoading;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              isEditing ? 'Edit Product' : 'Add Product',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.07),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing
                            ? 'Product Details'
                            : 'New Product Details',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Fill in the product information below.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('Product Name'),
                      TextFormField(
                        controller: _titleController,
                        textCapitalization:
                            TextCapitalization.sentences,
                        decoration:
                            _inputDecoration('Enter product name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Enter at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Price (₹)'),
                      TextFormField(
                        controller: _priceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}$'),
                          ),
                        ],
                        decoration:
                            _inputDecoration('Enter product price'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }

                          final price =
                              double.tryParse(value.trim());

                          if (price == null || price <= 0) {
                            return 'Enter a valid price greater than zero';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Available Stock'),
                      TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration(
                          'Enter available quantity',
                        ).copyWith(
                          prefixIcon: const Icon(
                            Icons.inventory_2_outlined,
                            color: primaryColor,
                          ),
                        ),
                        validator: _validateStock,
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Category'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        isExpanded: true,
                        decoration:
                            _inputDecoration('Select category'),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: textColor,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildLabel('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        textCapitalization:
                            TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Enter product description',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          if (value.trim().length < 10) {
                            return 'Enter at least 10 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      _buildLabel('Product Image'),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isPickingImage ? null : _pickImage,
                          icon: _isPickingImage
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(
                            _isPickingImage
                                ? 'Selecting image...'
                                : 'Upload Image',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(
                              color: primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Center(
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildLabel('Image URL'),
                      TextFormField(
                        controller: _imageController,
                        keyboardType: TextInputType.url,
                        decoration: _inputDecoration(
                          'Enter product image URL',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: _validateImage,
                      ),

                      if (_localImagePath != null ||
                          _imageController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _buildImagePreview(),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              isLoading || _isPickingImage
                                  ? null
                                  : _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primaryColor.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? 'Update Product'
                                      : 'Save Product',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
    );
  }

  Widget _buildImagePreview() {
    final localPath = _localImagePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Image Preview'),
            if (localPath != null)
              TextButton.icon(
                onPressed: _removeUploadedImage,
                icon: const Icon(
                  Icons.close,
                  size: 16,
                ),
                label: const Text('Remove upload'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
          ],
        ),
        Container(
          height: 170,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFD),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: borderColor),
          ),
          child: localPath != null
              ? Image.file(
                  File(localPath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      _buildNetworkImage(),
                )
              : _buildNetworkImage(),
        ),
      ],
    );
  }

  Widget _buildNetworkImage() {
    final imageUrl = _imageController.text.trim();

    if (imageUrl.isEmpty) {
      return const Icon(
        Icons.image_outlined,
        size: 42,
        color: Colors.grey,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 42,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'Unable to load image',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
