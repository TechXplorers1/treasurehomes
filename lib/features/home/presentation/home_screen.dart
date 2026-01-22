import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../services/presentation/providers/service_providers.dart';
import '../../categories/presentation/providers/category_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, userState),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(theme),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'Explore Categories', () {
                    context.push('/categories');
                  }),
                  const SizedBox(height: 16),
                  _buildCategoriesList(context),
                  const SizedBox(height: 30),
                  _buildPromotionalBanner(theme),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'Most Popular', () {}),
                  const SizedBox(height: 16),
                  _buildPopularServices(context, servicesAsync),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'All Services', () {}),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildAllServicesList(servicesAsync),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    AsyncValue<dynamic> userState,
  ) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: const AssetImage('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning 👋',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userState.value?.name ?? "Guest User",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search for "Plumbing"...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SizedBox(
      height: 100,
      child: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) return const SizedBox();
          // Limit to 5 for the horizontal list
          final displayCategories = categories.take(5).toList();

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = displayCategories[index];
              return GestureDetector(
                onTap: () {
                  context.push('/services-by-category/${cat.name}');
                },
                child: Column(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Color(cat.color),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(cat.iconName),
                        color: Colors.black54,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
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

  Widget _buildPromotionalBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withBlue(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            top: 20,
            right: 40,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LIMITED OFFER',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '30% OFF',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'On your first home cleaning',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServices(
    BuildContext context,
    AsyncValue<List<dynamic>> servicesAsync,
  ) {
    return servicesAsync.when(
      data: (services) => SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: services.take(3).length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final service = services[index];
            return _PopularServiceCard(service: service);
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildAllServicesList(AsyncValue<List<dynamic>> servicesAsync) {
    if (_searchQuery.isNotEmpty) {
      return SliverToBoxAdapter(
        child: servicesAsync.when(
          data: (services) {
            final filtered = services
                .where(
                  (s) => s.name.toString().toLowerCase().contains(_searchQuery),
                )
                .toList();
            if (filtered.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No services found"),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _ServiceListItem(
                service: filtered[index],
                onTap: () => context.push('/service/${filtered[index].id}'),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      );
    }

    return servicesAsync.when(
      data: (services) => SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final service = services[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
            child: _ServiceListItem(
              service: service,
              onTap: () => context.push('/service/${service.id}'),
            ),
          );
        }, childCount: services.length),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  final dynamic service;

  const _PopularServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service/${service.id}'),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.cleaning_services,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${service.price}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceListItem extends StatelessWidget {
  final dynamic service;
  final VoidCallback onTap;

  const _ServiceListItem({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.home_repair_service,
                  color: Colors.grey[400],
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Service",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.rating?.toString() ?? "4.5",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${service.price}/hr',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
