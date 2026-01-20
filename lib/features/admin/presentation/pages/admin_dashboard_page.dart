import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Total Users',
                  value: '1,245',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Active Bookings',
                  value: '45',
                  icon: Icons.calendar_month,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Revenue (Monthly)',
                  value: '\$12,500',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Active Subs',
                  value: '320',
                  icon: Icons.star,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Manage Customers'),
                  subtitle: const Text('View and edit customer details'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin/users'),
                ),
                ListTile(
                  leading: const Icon(Icons.room_service_outlined),
                  title: const Text('Manage Services'),
                  subtitle: const Text('Add, edit, or remove services'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Bookings & Orders'),
                  subtitle: const Text('Track all service requests'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin/bookings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
