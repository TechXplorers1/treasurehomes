import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/mock_admin_repository.dart';

class AdminBookingsPage extends ConsumerWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(adminBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Bookings')),
      body: bookingsAsync.when(
        data: (bookings) => ListView.separated(
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              leading: Icon(
                Icons.circle,
                size: 12,
                color: booking.status.name == 'completed'
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(booking.serviceName),
              subtitle: Text(
                '${booking.address}\n${DateFormat.yMMMd().format(booking.bookingDate)}',
              ),
              isThreeLine: true,
              trailing: Text(
                '\$${booking.totalPrice}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // View Details
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
