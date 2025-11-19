import 'dart:math';
import '../models/food_combo.dart';
import 'api_service.dart';

class FoodComboService {
  final ApiService _apiService = ApiService();

  /// Get all food combos from the backend
  Future<List<FoodCombo>> getAllFoodCombos() async {
    try {
      final response = await _apiService.get('/foodcombos/get-all-food-combos');

      if (!response.success) {
        return [];
      }

      if (response.data == null) {
        return [];
      }

      // El backend devuelve { success: true, combos: [...] }
      final List<dynamic> combosJson = response.data['combos'] as List<dynamic>;

      return combosJson.map((json) => FoodCombo.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a specific food combo by ID
  Future<FoodCombo?> getFoodComboById(String id) async {
    try {
      final response = await _apiService.get('/foodcombos/get-food-combo/$id');

      if (!response.success || response.data == null) {
        return null;
      }

      // El backend devuelve { success: true, combo: {...} }
      return FoodCombo.fromJson(response.data['combo']);
    } catch (e) {
      return null;
    }
  }

  /// Create a new food combo
  Future<bool> createFoodCombo(FoodCombo combo) async {
    try {
      // Generate a unique ID for the new food combo
      final comboId = _generateComboId();
      
      final response = await _apiService.post('/foodcombos/add-food-combo', body: {
        'id': comboId,
        'name': combo.name,
        'description': combo.description,
        'price': combo.price,
        'items': combo.items,
        'imageUrl': combo.imageUrl,
        'category': combo.category,
        'isAvailable': combo.isAvailable,
      });

      return response.success;
    } catch (e) {
      print('Error creating food combo: $e');
      return false;
    }
  }

  /// Update an existing food combo
  Future<bool> updateFoodCombo(FoodCombo combo) async {
    try {
      final response = await _apiService.put('/foodcombos/edit-food-combo/${combo.id}', body: {
        'name': combo.name,
        'description': combo.description,
        'price': combo.price,
        'items': combo.items,
        'imageUrl': combo.imageUrl,
        'category': combo.category,
        'isAvailable': combo.isAvailable,
      });

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Delete a food combo by ID
  Future<bool> deleteFoodCombo(String id) async {
    try {
      final response = await _apiService.delete('/foodcombos/delete-food-combo/$id');

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Generate a unique combo ID
  String _generateComboId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'COMBO_${timestamp}_$random';
  }
}