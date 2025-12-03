import 'dart:math';
import '../models/claim_ticket.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ClaimsService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Create a new claim ticket
  Future<ClaimTicket?> createClaim({
    required String title,
    required String description,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final claim = ClaimTicket(
        id: _generateClaimId(),
        userId: currentUser.uid,
        userEmail: currentUser.email,
        title: title,
        description: description,
        status: 'Open',
        createdAt: DateTime.now(),
      );

      final response = await _apiService.post(
        '/ClaimTicket',
        body: claim.toJson(),
      );

      if (response.success && response.data != null) {
        return ClaimTicket.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to create claim');
      }
    } catch (e) {
      throw Exception('Error creating claim: $e');
    }
  }

  /// Get all claims for the current user
  Future<List<ClaimTicket>> getUserClaims() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _apiService.get('/ClaimTicket');

      if (response.success && response.data != null) {
        final List<dynamic> claimsJson = response.data is List 
            ? response.data as List<dynamic>
            : [response.data];

        final allClaims = claimsJson
            .map((json) => ClaimTicket.fromJson(json))
            .toList();

        // Filter claims for current user only
        return allClaims
            .where((claim) => claim.userId == currentUser.uid)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching claims: $e');
    }
  }

  /// Get a specific claim by ID
  Future<ClaimTicket?> getClaimById(String id) async {
    try {
      final response = await _apiService.get('/ClaimTicket/$id');

      if (response.success && response.data != null) {
        final claim = ClaimTicket.fromJson(response.data);
        
        // Verify the claim belongs to current user
        final currentUser = _authService.currentUser;
        if (currentUser != null && claim.userId == currentUser.uid) {
          return claim;
        } else {
          throw Exception('Unauthorized access to claim');
        }
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching claim: $e');
    }
  }

  /// Update a claim (typically status updates by admin, but user can update description)
  Future<ClaimTicket?> updateClaim(ClaimTicket claim) async {
    try {
      // Verify the claim belongs to current user
      final currentUser = _authService.currentUser;
      if (currentUser == null || claim.userId != currentUser.uid) {
        throw Exception('Unauthorized to update this claim');
      }

      final response = await _apiService.put(
        '/ClaimTicket/${claim.id}',
        body: claim.toJson(),
      );

      if (response.success && response.data != null) {
        return ClaimTicket.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to update claim');
      }
    } catch (e) {
      throw Exception('Error updating claim: $e');
    }
  }

  /// Delete a claim (only if user owns it and it's still open)
  Future<bool> deleteClaim(String id) async {
    try {
      final claim = await getClaimById(id);
      if (claim == null) {
        throw Exception('Claim not found');
      }

      // Only allow deletion if claim is still open
      if (!claim.isOpen) {
        throw Exception('Cannot delete claim that is already being processed or closed');
      }

      final response = await _apiService.delete('/ClaimTicket/$id');
      return response.success;
    } catch (e) {
      throw Exception('Error deleting claim: $e');
    }
  }

  /// Get claims filtered by status
  Future<List<ClaimTicket>> getClaimsByStatus(String status) async {
    try {
      final allClaims = await getUserClaims();
      return allClaims.where((claim) => claim.status == status).toList();
    } catch (e) {
      throw Exception('Error filtering claims: $e');
    }
  }

  /// Get ALL claims for admin use (without user filtering)
  Future<List<ClaimTicket>> getAllClaimsForAdmin() async {
    try {
      final response = await _apiService.get('/ClaimTicket');

      if (response.success && response.data != null) {
        final List<dynamic> claimsJson = response.data is List 
            ? response.data as List<dynamic>
            : [response.data];

        return claimsJson
            .map((json) => ClaimTicket.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching all claims: $e');
    }
  }

  /// Get claim statistics for the user
  Future<Map<String, int>> getClaimStatistics() async {
    try {
      final allClaims = await getUserClaims();
      
      return {
        'total': allClaims.length,
        'open': allClaims.where((c) => c.isOpen).length,
        'inProgress': allClaims.where((c) => c.isInProgress).length,
        'closed': allClaims.where((c) => c.isClosed).length,
      };
    } catch (e) {
      return {
        'total': 0,
        'open': 0,
        'inProgress': 0,
        'closed': 0,
      };
    }
  }

  /// Get claim statistics for admin (all claims)
  Future<Map<String, int>> getAdminClaimStatistics() async {
    try {
      final allClaims = await getAllClaimsForAdmin();
      
      return {
        'total': allClaims.length,
        'open': allClaims.where((c) => c.isOpen).length,
        'inProgress': allClaims.where((c) => c.isInProgress).length,
        'closed': allClaims.where((c) => c.isClosed).length,
      };
    } catch (e) {
      return {
        'total': 0,
        'open': 0,
        'inProgress': 0,
        'closed': 0,
      };
    }
  }

  /// Generate a unique ID for new claims
  String _generateClaimId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'CLAIM_${timestamp}_$random';
  }
}