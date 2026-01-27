import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../services/presentation/providers/service_providers.dart';

import '../../../categories/presentation/providers/category_provider.dart';

class AddEditServicePage extends ConsumerStatefulWidget {
  final ServiceEntity? service;

  const AddEditServicePage({super.key, this.service});

  @override
  ConsumerState<AddEditServicePage> createState() => _AddEditServicePageState();
}

class _AddEditServicePageState extends ConsumerState<AddEditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailedDescriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  String? _selectedCategory;
  bool _isLoading = false;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.service?.description ?? '',
    );
    _detailedDescriptionController = TextEditingController(
      text: widget.service?.detailedDescription ?? '',
    );
    _priceController = TextEditingController(
      text: widget.service?.price.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.service?.imageUrl ?? '',
    );
    _selectedCategory = widget.service?.category;

    // Trigger check/seed if needed (safe to call here)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkAndSeedCategoriesProvider);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _detailedDescriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child(
        'service_images/$fileName',
      );
      await ref.putFile(_imageFile!);
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        _imageUrlController.text = downloadUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(serviceRepositoryProvider);
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final detailedDescription = _detailedDescriptionController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final imageUrl = _imageUrlController.text.trim();

      final serviceData = ServiceEntity(
        id:
            widget.service?.id ??
            '', // ID handled by repo for new items usually
        name: name,
        description: description,
        price: price,
        category: _selectedCategory ?? 'Other',
        rating: widget.service?.rating,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        detailedDescription: detailedDescription,
      );

      if (widget.service == null) {
        await repository.addService(serviceData);
      } else {
        await repository.updateService(serviceData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.service == null
                  ? 'Service added successfully'
                  : 'Service updated successfully',
            ),
          ),
        );

        // Refresh the list
        ref.invalidate(servicesProvider);
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'Add Service' : 'Edit Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... text fields ...
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailedDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description (Content Page)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) => null, // Optional field
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: categoriesAsync.when(
                      data: (categories) {
                        // Ensure selected category is valid or null
                        if (_selectedCategory != null &&
                            !categories.any(
                              (c) => c.name == _selectedCategory,
                            )) {
                          // Keep it if editing, maybe it was deleted?
                          // But usually we should force pick a valid one.
                          // For now, let's keep it to act as "Other" or let user change it.
                          // actually, DropdownButton will crash if value is not in items.
                          // So we must add it or nullify it.
                          // Simpler: Just rely on user to pick.
                          // If valid, use it.
                        }

                        final uniqueCategories = categories
                            .map((c) => c.name)
                            .toSet()
                            .toList();
                        // Add selected if not in list (to avoid crash), or handle it.
                        if (_selectedCategory != null &&
                            !uniqueCategories.contains(_selectedCategory)) {
                          uniqueCategories.add(_selectedCategory!);
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: uniqueCategories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedCategory = newValue);
                            }
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a category'
                              : null,
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error loading categories'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => null, // Optional
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_upload),
                      onPressed: _isUploading ? null : _pickImage,
                      tooltip: 'Upload Image',
                    ),
                  ),
                ],
              ),
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 150,
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Invalid Image URL'));
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveService,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.service == null
                            ? 'Create Service'
                            : 'Update Service',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
