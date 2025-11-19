import 'dart:math';
import '../models/food_order.dart';
import 'api_service.dart';

class FoodOrderService {
  final ApiService _apiService = ApiService();

  /// Get all food orders
  Future<List<FoodOrder>> getAllFoodOrders() async {
    try {
      final response = await _apiService.get('/foodorders/get-all-food-orders');
      
      if (response.success && response.data['orders'] != null) {
        final List<dynamic> ordersJson = response.data['orders'];
        return ordersJson.map((json) => FoodOrder.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading food orders: $e');
      return [];
    }
  }

  /// Get a food order by ID
  Future<FoodOrder?> getFoodOrderById(String id) async {
    try {
      final response = await _apiService.get('/foodorders/get-food-order/$id');
      
      if (response.success && response.data['order'] != null) {
        return FoodOrder.fromJson(response.data['order']);
      }
      
      return null;
    } catch (e) {
      print('Error loading food order: $e');
      return null;
    }
  }

  /// Create a new food order
  Future<bool> createFoodOrder(FoodOrder order) async {
    try {
      // Generate a unique ID for the new order
      final orderId = _generateOrderId();
      
      final response = await _apiService.post('/foodorders/add-food-order', body: {
        'id': orderId,
        'userId': order.userId,
        'foodComboIds': order.foodComboIds,
        'totalPrice': order.totalPrice,
        'status': order.status,
      });

      return response.success;
    } catch (e) {
      print('Error creating food order: $e');
      return false;
    }
  }

  /// Update an existing food order
  Future<bool> updateFoodOrder(FoodOrder order) async {
    try {
      final response = await _apiService.put('/foodorders/edit-food-order/${order.id}', body: {
        'id': order.id,
        'userId': order.userId,
        'foodComboIds': order.foodComboIds,
        'totalPrice': order.totalPrice,
        'status': order.status,
      });

      return response.success;
    } catch (e) {
      print('Error updating food order: $e');
      return false;
    }
  }

  /// Delete a food order
  Future<bool> deleteFoodOrder(String id) async {
    try {
      final response = await _apiService.delete('/foodorders/delete-food-order/$id');
      return response.success;
    } catch (e) {
      print('Error deleting food order: $e');
      return false;
    }
  }

  /// Update food order status
  Future<bool> updateOrderStatus(String id, String status) async {
    try {
      final order = await getFoodOrderById(id);
      if (order == null) return false;

      final updatedOrder = order.copyWith(
        status: status,
        updatedAt: DateTime.now().toUtc(),
      );

      return await updateFoodOrder(updatedOrder);
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Generate a unique order ID
  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return 'ORD_${timestamp}_$random';
  }
}