import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/showtime.dart';
import '../../../core/models/seat.dart';
import '../../../core/models/food_item.dart';
import '../../../core/models/screening.dart';
import '../../../core/providers/service_providers.dart';

/// State for the current booking flow
class BookingState {
  final MovieModel? selectedMovie;
  final Showtime? selectedShowtime;
  final List<Seat> selectedSeats;
  final List<CartItem> foodCart;
  final String? bookingId;
  final String? promoCode;
  final double promoDiscount;

  const BookingState({
    this.selectedMovie,
    this.selectedShowtime,
    this.selectedSeats = const [],
    this.foodCart = const [],
    this.bookingId,
    this.promoCode,
    this.promoDiscount = 0.0,
  });

  BookingState copyWith({
    MovieModel? selectedMovie,
    Showtime? selectedShowtime,
    List<Seat>? selectedSeats,
    List<CartItem>? foodCart,
    String? bookingId,
    String? promoCode,
    double? promoDiscount,
  }) {
    return BookingState(
      selectedMovie: selectedMovie ?? this.selectedMovie,
      selectedShowtime: selectedShowtime ?? this.selectedShowtime,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      foodCart: foodCart ?? this.foodCart,
      bookingId: bookingId ?? this.bookingId,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
    );
  }

  double get seatsTotal {
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.type.price);
  }

  double get foodTotal {
    return foodCart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get subtotal => seatsTotal + foodTotal;

  double get totalPrice => (subtotal - promoDiscount).clamp(0, double.infinity);

  int get seatCount => selectedSeats.length;

  int get foodItemCount {
    return foodCart.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get hasSelection => selectedSeats.isNotEmpty;

  bool get hasFoodItems => foodCart.isNotEmpty;
}

/// Booking state notifier
class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => const BookingState();

  void setMovie(MovieModel movie) {
    state = state.copyWith(selectedMovie: movie);
  }

  void setShowtime(Showtime showtime) {
    state = state.copyWith(
      selectedShowtime: showtime,
      selectedSeats: [], // Reset seats when changing showtime
    );
  }

  void toggleSeat(Seat seat) {
    final currentSeats = List<Seat>.from(state.selectedSeats);

    // Check if seat is already selected
    final index = currentSeats.indexWhere((s) => s.id == seat.id);

    if (index != -1) {
      // Deselect seat
      currentSeats.removeAt(index);
    } else {
      // Select seat (max 8 seats)
      if (currentSeats.length < 8) {
        currentSeats.add(seat);
      }
    }

    state = state.copyWith(selectedSeats: currentSeats);
  }

  bool isSeatSelected(String seatId) {
    return state.selectedSeats.any((s) => s.id == seatId);
  }

  void clearSelection() {
    state = state.copyWith(selectedSeats: []);
  }

  void setBookingId(String bookingId) {
    state = state.copyWith(bookingId: bookingId);
  }

  void reset() {
    state = const BookingState();
  }

  // Food cart methods
  void addFoodItem(FoodItem foodItem) {
    final currentCart = List<CartItem>.from(state.foodCart);
    final existingIndex =
        currentCart.indexWhere((item) => item.foodItem.id == foodItem.id);

    if (existingIndex != -1) {
      // Increment quantity
      currentCart[existingIndex] = currentCart[existingIndex].copyWith(
        quantity: currentCart[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      currentCart.add(CartItem(foodItem: foodItem, quantity: 1));
    }

    state = state.copyWith(foodCart: currentCart);
  }

  void removeFoodItem(String foodItemId) {
    final currentCart = List<CartItem>.from(state.foodCart);
    final existingIndex =
        currentCart.indexWhere((item) => item.foodItem.id == foodItemId);

    if (existingIndex != -1) {
      if (currentCart[existingIndex].quantity > 1) {
        // Decrement quantity
        currentCart[existingIndex] = currentCart[existingIndex].copyWith(
          quantity: currentCart[existingIndex].quantity - 1,
        );
      } else {
        // Remove item
        currentCart.removeAt(existingIndex);
      }
    }

    state = state.copyWith(foodCart: currentCart);
  }

  void clearFoodCart() {
    state = state.copyWith(foodCart: []);
  }

  int getFoodItemQuantity(String foodItemId) {
    final item = state.foodCart.firstWhere(
      (item) => item.foodItem.id == foodItemId,
      orElse: () => CartItem(
        foodItem: mockFoodItems.first,
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Promo code methods
  bool applyPromoCode(String code) {
    final upperCode = code.trim().toUpperCase();
    double discount = 0.0;

    switch (upperCode) {
      case '2X1CINE':
        // 50% off on total
        discount = state.subtotal * 0.5;
        break;
      case 'FAMILIA':
        // Fixed 5000 colones off
        discount = 5000.0;
        break;
      case 'HAPPYHOUR':
        // 30% off on total
        discount = state.subtotal * 0.3;
        break;
      case 'ESTUDIANTE':
        // 25% off on total
        discount = state.subtotal * 0.25;
        break;
      default:
        // Invalid code
        return false;
    }

    state = state.copyWith(
      promoCode: upperCode,
      promoDiscount: discount,
    );
    return true;
  }

  void removePromoCode() {
    state = state.copyWith(
      promoCode: null,
      promoDiscount: 0.0,
    );
  }
}

/// Provider for booking state
final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});

/// Helper function to convert Screening to Showtime
Showtime _screeningToShowtime(Screening screening) {
  // Generate mock seats for the screening
  final seats = generateMockSeats(
    rows: 8,
    seatsPerRow: 12,
    // Randomly occupy some seats for realism
    occupiedSeats: _generateRandomOccupiedSeats(),
  );

  return Showtime(
    id: screening.id, // Use the real screening ID from backend
    movieId: screening.movieId,
    cinemaHall: screening.theaterRoomId,
    dateTime: screening.startTime,
    seats: seats,
    totalSeats: 96,
    availableSeats: seats.where((s) => s.status == SeatStatus.available).length,
  );
}

/// Generate random occupied seats for demo purposes
List<String> _generateRandomOccupiedSeats() {
  final random = DateTime.now().millisecondsSinceEpoch % 10;
  final occupied = <String>[];

  // Add 5-10 random occupied seats
  for (int i = 0; i < random; i++) {
    final row = i % 8;
    final seat = (i * 3) % 12 + 1;
    occupied.add('R${row}S$seat');
  }

  return occupied;
}

/// Provider for available showtimes - fetches from backend
final showtimesProvider = FutureProvider.family<List<Showtime>, String>((ref, movieId) async {
  try {
    final screeningService = ref.watch(screeningServiceProvider);
    final screenings = await screeningService.getScreeningsByMovieId(movieId);

    // Filter only future screenings
    final futureScreenings = screenings.where((s) => s.isFuture).toList();

    // Convert screenings to showtimes
    return futureScreenings.map((screening) => _screeningToShowtime(screening)).take(5).toList();
  } catch (e) {
    print('Error fetching showtimes: $e');
    // Fallback to mock data if API fails
    return getMockShowtimes(movieId).take(5).toList();
  }
});
