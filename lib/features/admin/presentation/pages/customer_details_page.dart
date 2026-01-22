import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:home_services_app/features/auth/domain/entities/user_entity.dart';
import 'package:home_services_app/features/bookings/presentation/providers/booking_provider.dart';
import 'package:home_services_app/features/bookings/domain/entities/booking_entity.dart';

class CustomerDetailsPage extends ConsumerWidget {
  final UserEntity user;

  const CustomerDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(
      specificUserBookingsProviderFamily(user.id),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(context, user),
            const SizedBox(height: 16),
            _buildSubscriptionCard(context),
            const SizedBox(height: 16),
            Text(
              'Booking History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            bookingsAsync.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No bookings found')),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _BookingCard(booking: bookings[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    final registrationDate = user.createdAt != null
        ? DateFormat('MMM d, yyyy h:mm a').format(user.createdAt!)
        : 'Unknown';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(user.email, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.role == UserRole.admin
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: user.role == UserRole.admin
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                        child: Text(
                          user.role.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: user.role == UserRole.admin
                                ? Colors.red
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow('Registration Date', registrationDate),
            const SizedBox(height: 8),
            _buildInfoRow('Account ID', user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SelectableText(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    // Placeholder for subscription details as no real data source exists yet
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subscription Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Current Plan', 'Premium Plan'), // Mock data
            const SizedBox(height: 8),
            _buildInfoRow('Renewal Date', 'Feb 21, 2026'), // Mock data
            const SizedBox(height: 8),
            _buildInfoRow('Price', '\$29.99/mo'), // Mock data
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Manage Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        break;
      case BookingStatus.pending:
        statusColor = Colors.orange;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        break;
      case BookingStatus.workInProgress:
        statusColor = Colors.purple;
        break;
      case BookingStatus.completed:
        statusColor = Colors.blue;
        break;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(
          booking.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('MMM d, yyyy').format(booking.bookingDate)}',
            ),
            Text('Price: \$${booking.totalPrice.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            booking.status.name.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
