import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'customer_details_page.dart';
import 'add_user_page.dart';

final adminUsersStreamProvider = StreamProvider<List<UserEntity>>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserEntity(
        id: doc.id,
        email: data['email'] ?? '',
        name: data['name'] ?? 'Unknown',
        phoneNumber: data['phoneNumber'],
        role: _parseUserRole(data['role'] ?? 'customer'),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  });
});

UserRole _parseUserRole(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'provider':
      return UserRole.provider;
    case 'customer':
    default:
      return UserRole.customer;
  }
}

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Customers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserPage()),
          );
        },
        label: const Text('Add User'),
        icon: const Icon(Icons.add),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(user.name),
                subtitle: Text('${user.email} (${user.role.name})'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailsPage(user: user),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
