import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../categories/presentation/providers/category_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure seeding triggers if empty (optional here as home screen might have already triggered it, but safe to include)
    ref.watch(checkAndSeedCategoriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Categories',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  context.push('/services-by-category/${cat.name}');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(cat.color),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(cat.iconName),
                          color: Colors.black54,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
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
    return iconMap[iconName] ?? Icons.category;
  }
}
