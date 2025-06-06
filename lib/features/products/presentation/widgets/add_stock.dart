import 'dart:io';
import 'package:agri_connect/features/auth/presentation/widgets/auth_gradient.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddStockForm extends ConsumerStatefulWidget {
  final String userId;
  final StockModel? stockToEdit;
  final void Function(StockModel, List<XFile>) onSubmit;

  const AddStockForm({
    super.key,
    required this.userId,
    required this.onSubmit,
    this.stockToEdit,
  });

  @override
  ConsumerState<AddStockForm> createState() => _AddStockFormState();
}

class _AddStockFormState extends ConsumerState<AddStockForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  int? _categoryId;

  final List<XFile> _pickedImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.stockToEdit != null;

      final stock = StockModel(
        id: isEditing ? widget.stockToEdit!.id : const Uuid().v4(),
        userId: widget.userId,
        categoryId: _categoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        quantity: int.parse(_quantityController.text.trim()),
        images: isEditing ? widget.stockToEdit!.images ?? [] : [],
        createdAt: isEditing ? widget.stockToEdit!.createdAt : DateTime.now(),
      );

      if (!isEditing && _pickedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
        );
        return;
      }

      widget.onSubmit(stock, _pickedImages);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.stockToEdit != null) {
      final s = widget.stockToEdit!;
      _nameController.text = s.name;
      _descriptionController.text = s.description ?? '';
      _priceController.text = s.price.toString();
      _quantityController.text = s.quantity.toString();
      _categoryId = s.categoryId;
      // Note: Don't pre-fill images as they are URLs and not XFile
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.stockToEdit != null;
    final categoryAsync = ref.watch(categoryProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Update Stock' : 'Add New Stock',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Name is required'
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price per Unit'),
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      double.tryParse(value ?? '') == null
                          ? 'Enter valid price'
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      int.tryParse(value ?? '') == null
                          ? 'Enter valid quantity'
                          : null,
            ),
            const SizedBox(height: 12),

            categoryAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
              data: (categories) {
                return DropdownButtonFormField<int>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => _categoryId = val),
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._pickedImages.map(
                  (img) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(img.path),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            AuthGradient(
              text: isEditing ? 'Update Stock' : 'Add Stock',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
