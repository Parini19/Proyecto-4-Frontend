import 'food_item.dart';

/// Food combo model that matches the backend FoodCombo entity
class FoodCombo {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> items;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  const FoodCombo({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.items,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });

  factory FoodCombo.fromJson(Map<String, dynamic> json) {
    return FoodCombo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      items: List<String>.from(json['items'] ?? []),
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'items': items,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  /// Convert to FoodItem for compatibility with existing UI components
  FoodItem toFoodItem() {
    return FoodItem(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: FoodCategory.combo,
      isAvailable: isAvailable,
    );
  }

  FoodCombo copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? items,
    String? imageUrl,
    String? category,
    bool? isAvailable,
  }) {
    return FoodCombo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      items: items ?? this.items,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Mock food combos for development
final List<FoodCombo> mockFoodCombos = [
  FoodCombo(
    id: 'FC1',
    name: 'Combo Clásico',
    description: 'Palomitas medianas + Refresco mediano',
    price: 150.0,
    items: ['Palomitas Medianas', 'Refresco Mediano'],
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo1.jpg',
    category: 'combo',
  ),
  FoodCombo(
    id: 'FC2',
    name: 'Combo Pareja',
    description: 'Palomitas grandes + 2 Refrescos medianos',
    price: 250.0,
    items: ['Palomitas Grandes', 'Refresco Mediano x2'],
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo2.jpg',
    category: 'combo',
  ),
  FoodCombo(
    id: 'FC3',
    name: 'Combo Familia',
    description: 'Palomitas jumbo + 4 Refrescos medianos + 2 Nachos',
    price: 450.0,
    items: ['Palomitas Jumbo', 'Refresco Mediano x4', 'Nachos x2'],
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo3.jpg',
    category: 'combo',
  ),
  FoodCombo(
    id: 'FC4',
    name: 'Combo Dulce',
    description: 'M&Ms + Skittles + Refresco chico',
    price: 120.0,
    items: ['M&Ms', 'Skittles', 'Refresco Chico'],
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo4.jpg',
    category: 'dulces',
  ),
  FoodCombo(
    id: 'FC5',
    name: 'Combo Snack',
    description: 'Nachos + Palomitas chicas + Agua',
    price: 165.0,
    items: ['Nachos', 'Palomitas Chicas', 'Agua Embotellada'],
    imageUrl: 'https://image.tmdb.org/t/p/w500/combo5.jpg',
    category: 'snacks',
  ),
];