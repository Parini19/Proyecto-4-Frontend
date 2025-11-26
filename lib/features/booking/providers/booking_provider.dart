import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/showtime.dart';
import '../../../core/models/seat.dart';
import '../../../core/models/food_item.dart';

/// State for the current booking flow
class BookingState {
  final MovieModel? selectedMovie;
  final Showtime? selectedShowtime;
  final List<Seat> selectedSeats;
  final List<CartItem> foodCart;
  final String? bookingId;

  const BookingState({
    this.selectedMovie,
    this.selectedShowtime,
    this.selectedSeats = const [],
    this.foodCart = const [],
    this.bookingId,
  });

  BookingState copyWith({
    MovieModel? selectedMovie,
    Showtime? selectedShowtime,
    List<Seat>? selectedSeats,
    List<CartItem>? foodCart,
    String? bookingId,
  }) {
    return BookingState(
      selectedMovie: selectedMovie ?? this.selectedMovie,
      selectedShowtime: selectedShowtime ?? this.selectedShowtime,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      foodCart: foodCart ?? this.foodCart,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  double get seatsTotal {
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.type.price);
  }

  double get foodTotal {
    return foodCart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalPrice => seatsTotal + foodTotal;

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
}

/// Provider for booking state
final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});

/// Provider for available showtimes
final showtimesProvider = Provider.family<List<Showtime>, String>((ref, movieId) {
  return getMockShowtimes(movieId);
});
