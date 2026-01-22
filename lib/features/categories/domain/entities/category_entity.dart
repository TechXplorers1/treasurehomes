import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconName; // e.g. 'plumbing', 'electrical' to map to IconData
  final int color; // Hex color value

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'iconName': iconName, 'color': color};
  }

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'help', // Default icon
      color: map['color'] ?? 0xFFEEEEEE, // Default color
    );
  }

  @override
  List<Object?> get props => [id, name, iconName, color];
}
