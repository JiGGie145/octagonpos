import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/core/utils/image_helper.dart';
import 'package:flutter_pos/domain/entities/product.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _imagePath;
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
    _imagePath = widget.product?.imageUrl;
    _isActive = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      final savedPath = await saveProductImage(File(picked.path));
      setState(() => _imagePath = savedPath);
    }
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

              // Product image (optional)
              _buildImagePicker(context),
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

  Widget _buildImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = _imagePath != null && _imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Image (optional)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _isSaving ? null : _pickImage,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage ? _buildImagePreview(theme) : _buildPlaceholder(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    final isLocal = isLocalImagePath(_imagePath!);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (isLocal)
          Image.file(File(_imagePath!), fit: BoxFit.cover)
        else
          Image.network(_imagePath!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(theme)),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: IconButton.filled(
            onPressed: _isSaving
                ? null
                : () => setState(() => _imagePath = null),
            icon: const Icon(Icons.close, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
              foregroundColor: theme.colorScheme.onSurface,
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 36, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tap to add image',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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

      await widget.onSave(
        name,
        priceInCents,
        category,
        _isActive,
        _imagePath,
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
