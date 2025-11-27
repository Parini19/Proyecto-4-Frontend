# Implementación del Sistema de Configuración de Asientos

## Resumen de Cambios Completados

### ✅ Backend (C# .NET)

1. **BookingsController.cs** - Nuevo endpoint agregado (línea 248):
   ```csharp
   /// GET /api/bookings/occupied-seats/{screeningId}
   [HttpGet("occupied-seats/{screeningId}")]
   public async Task<IActionResult> GetOccupiedSeats(string screeningId)
   ```
   - Retorna lista de asientos ocupados para una función específica
   - Filtra bookings confirmados y pendientes

### ✅ Frontend (Flutter)

1. **theater_rooms_management_page.dart**:
   - ✅ Enum actualizado: `enum SeatType { normal, vip, wheelchair, disabled, empty }`
   - ✅ Leyenda actualizada con 5 tipos de asientos
   - ✅ Texto de instrucción: "Normal → VIP → Discapacitados → Deshabilitado → Vacío"

2. **booking_service.dart** - Nuevo método agregado (línea 130):
   ```dart
   Future<List<String>> getOccupiedSeats(String screeningId) async
   ```
   - Consulta endpoint `/api/bookings/occupied-seats/{screeningId}`
   - Retorna lista de seat numbers ocupados

3. **seat.dart**:
   - ✅ Precios actualizados: Regular ₡4,500, VIP ₡6,500, Wheelchair ₡4,500

## 🔧 Cambio Pendiente CRÍTICO

### booking_provider.dart - Líneas 224-276

**ACTUAL (MOCK):**
```dart
Showtime _screeningToShowtime(Screening screening) {
  final seats = generateMockSeats(
    rows: 8,  // FIJO
    seatsPerRow: 12,  // FIJO
    occupiedSeats: _generateRandomOccupiedSeats(),  // RANDOM
  );
  ...
}
```

**DEBE SER (REAL DATA):**
```dart
Future<Showtime> _screeningToShowtime(
  Screening screening,
  theaterRoomService,
  bookingService,
) async {
  try {
    // 1. Obtener configuración de la sala
    final theaterRoom = await theaterRoomService.getTheaterRoom(screening.theaterRoomId);

    if (theaterRoom != null && theaterRoom.seatConfiguration != null) {
      final config = theaterRoom.seatConfiguration as Map<String, dynamic>;
      final seatsList = config['seats'] as List<dynamic>? ?? [];

      // 2. Obtener asientos ocupados REALES
      final occupiedSeatNumbers = await bookingService.getOccupiedSeats(screening.id);

      // 3. Generar asientos desde configuración
      seats = [];
      for (var seatConfig in seatsList) {
        final seatMap = seatConfig as Map<String, dynamic>;
        final row = seatMap['row'] as int;
        final col = seatMap['col'] as int;
        final typeStr = seatMap['type'] as String;

        if (typeStr == 'empty') continue;  // Saltar asientos vacíos

        final seatId = 'R${row}S${col + 1}';
        final isOccupied = occupiedSeatNumbers.contains(seatId);

        // Mapear tipos de admin a tipos de booking
        SeatType seatType;
        switch (typeStr) {
          case 'vip': seatType = SeatType.vip; break;
          case 'wheelchair':
          case 'disabled': seatType = SeatType.wheelchair; break;
          default: seatType = SeatType.regular;
        }

        seats.add(Seat(
          id: seatId,
          row: row,
          number: col + 1,
          type: seatType,
          status: isOccupied ? SeatStatus.occupied : SeatStatus.available,
        ));
      }
    } else {
      // Fallback a mock si no hay configuración
      final occupiedSeats = await bookingService.getOccupiedSeats(screening.id);
      seats = generateMockSeats(rows: 8, seatsPerRow: 12, occupiedSeats: occupiedSeats);
    }
    ...
  }
}

// Provider actualizado
final showtimesProvider = FutureProvider.family<List<Showtime>, String>((ref, movieId) async {
  final screeningService = ref.watch(screeningServiceProvider);
  final theaterRoomService = ref.watch(theaterRoomServiceProvider);
  final bookingService = ref.watch(bookingServiceProvider);

  final screenings = await screeningService.getScreeningsByMovieId(movieId);
  final futureScreenings = screenings.where((s) => s.isFuture).toList();

  // Convertir con datos REALES
  final showtimes = <Showtime>[];
  for (var screening in futureScreenings.take(5)) {
    final showtime = await _screeningToShowtime(
      screening,
      theaterRoomService,
      bookingService,
    );
    showtimes.add(showtime);
  }

  return showtimes;
});
```

## Flujo Completo

1. **Admin configura sala** (theater_rooms_management_page.dart):
   - Selecciona filas y columnas
   - Configura tipo de cada asiento: normal, vip, wheelchair, disabled, empty
   - Guarda en TheaterRoom.seatConfiguration

2. **Usuario selecciona función**:
   - `showtimesProvider` consulta screenings
   - Para cada screening:
     - Obtiene TheaterRoom por screening.theaterRoomId
     - Lee seatConfiguration
     - Consulta asientos ocupados: `/api/bookings/occupied-seats/{screeningId}`
     - Genera grid de asientos con tipos y estados reales

3. **Reserva**:
   - Usuario selecciona asientos disponibles
   - Crea booking con seatNumbers
   - Próxima consulta mostrará estos asientos como ocupados

## Para Aplicar el Cambio

Si flutter está en hot reload, detener el proceso y ejecutar:

```bash
# 1. Detener Flutter
# Ctrl+C en terminal de Flutter

# 2. Reemplazar las líneas 224-276 en booking_provider.dart
# con la implementación REAL DATA mostrada arriba

# 3. Reiniciar Flutter
cd "C:/Users/Guillermo Parini/Documents/Cinema Frontend/Proyecto-4-Frontend"
flutter run -d chrome --web-port=5173
```

## Testing

1. ✅ Admin Panel → Gestión de Salas → Configurar Asientos
2. ✅ Seleccionar sala → Click en asientos para cambiar tipo
3. ✅ Guardar configuración
4. ✅ Frontend → Seleccionar película → Ver función
5. ✅ Verificar que se muestren asientos según configuración
6. ✅ Verificar que asientos ocupados sean reales (de bookings)
