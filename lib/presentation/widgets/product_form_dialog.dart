import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/domain/entities/product.dart';

/// Add/Edit product dialog.
///
/// When [product] is provided, the form is pre-populated for editing.
/// [onSave] receives the validated form values — the caller is responsible
/// for calling the appropriate use case and invalidating providers.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  /// If non-null, the dialog is in "edit" mode with pre-populated fields.
  final Product? product;

  /// Called with (name, priceInCents, category, isActive, imageUrl) on save.
  final Future<void> Function(
    String name,
    int priceInCents,
    String category,
    bool isActive,
    String? imageUrl,
  ) onSave;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageUrlController;
  late bool _isActive;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  /// Default category suggestions.
  static const _defaultCategories = [
    'Beverages',
    'Food',
    'Snacks',
    'Desserts',
    'Bakery',
    'Dairy',
    'Fruit',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    // Show price in major units for user-friendly editing (e.g. 35.00 not 3500)
    _priceController = TextEditingController(
      text: widget.product != null
          ? (widget.product!.price / 100).toStringAsFixed(2)
          : '',
    );
    _categoryController =
        TextEditingController(text: widget.product?.category ?? '');
    _imageUrlController =
        TextEditingController(text: widget.product?.imageUrl ?? '');
    _isActive = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Cappuccino',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Price (user enters in major units, stored as cents)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'e.g. 35.00',
                  prefixText: ' ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Category (autocomplete with free-text entry)
              Autocomplete<String>(
                initialValue: _categoryController.value,
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _defaultCategories;
                  }
                  return _defaultCategories.where((c) => c
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (value) {
                  _categoryController.text = value;
                },
                fieldViewBuilder:
                    (context, textController, focusNode, onSubmitted) {
                  // Keep our controller in sync
                  textController.addListener(() {
                    _categoryController.text = textController.text;
                  });
                  return TextFormField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'e.g. Beverages',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Image URL (optional)
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Active toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(
                  _isActive
                      ? 'Product is visible in the POS'
                      : 'Product is hidden from the POS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                value: _isActive,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Text(_isEditing ? 'SAVE' : 'ADD'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final priceInCents =
          (double.parse(_priceController.text.trim()) * 100).round();
      final category = _categoryController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      await widget.onSave(
        name,
        priceInCents,
        category,
        _isActive,
        imageUrl.isEmpty ? null : imageUrl,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? '"$name" updated successfully'
                  : '"$name" added successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
