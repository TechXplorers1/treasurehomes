import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';

class AddEditCategoryPage extends ConsumerStatefulWidget {
  final CategoryEntity? category;

  const AddEditCategoryPage({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryPage> createState() =>
      _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends ConsumerState<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIconName;
  late int _selectedColor;
  bool _isSaving = false;

  final Map<String, IconData> _availableIcons = {
    'plumbing': Icons.plumbing,
    'electrical_services': Icons.electrical_services,
    'cleaning_services': Icons.cleaning_services,
    'construction': Icons.construction,
    'ac_unit': Icons.ac_unit,
    'format_paint': Icons.format_paint,
    'pest_control': Icons.pest_control,
    'yard': Icons.yard,
    'move_to_inbox': Icons.move_to_inbox,
    'home_repair_service': Icons.home_repair_service,
    'build': Icons.build,
    'brush': Icons.brush,
    'bug_report': Icons.bug_report,
    'grass': Icons.grass,
    'local_shipping': Icons.local_shipping,
  };

  final List<int> _availableColors = [
    0xFFE3F2FD, // Blue
    0xFFFFF8E1, // Amber
    0xFFE8F5E9, // Green
    0xFFFCE4EC, // Pink
    0xFFE0F7FA, // Cyan
    0xFFF3E5F5, // Purple
    0xFFFFEBEE, // Red
    0xFFFFF3E0, // Orange
    0xFFF5F5F5, // Grey
    0xFFE1BEE7, // Deep Purple
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIconName = widget.category?.iconName ?? 'build';
    _selectedColor = widget.category?.color ?? _availableColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(categoryRepositoryProvider);
      final id = widget.category?.id ?? const Uuid().v4();

      final category = CategoryEntity(
        id: id,
        name: _nameController.text.trim(),
        iconName: _selectedIconName,
        color: _selectedColor,
      );

      if (widget.category != null) {
        await repository.updateCategory(category);
      } else {
        await repository.addCategory(category);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category != null
                  ? 'Category updated successfully'
                  : 'Category added successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving category: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Icon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableIcons.entries.map((entry) {
                  final isSelected = _selectedIconName == entry.key;
                  return InkWell(
                    onTap: () => setState(() => _selectedIconName = entry.key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey[100],
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entry.value,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Background Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.black54)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.category != null
                              ? 'Update Category'
                              : 'Add Category',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
