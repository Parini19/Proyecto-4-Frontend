# 🎬 Guía Completa de Pruebas - Cinema App

**Fecha:** 2025-11-04
**Versión:** 1.0 - Flujo de Usuario Completo

---

## 🚀 Cómo Ejecutar la App

### Opción 1: Web (Chrome) - Más Rápido ⚡
```bash
cd "../Cinema Frontend/Proyecto-4-Frontend"
flutter run -d chrome --web-port=5174
```
- **URL:** http://localhost:5174
- **Ventaja:** Compila rápido (15-30 seg), hot reload instantáneo
- **Desventaja:** No prueba gestos táctiles nativos

### Opción 2: Android Emulador 📱
```bash
# 1. Iniciar emulador (si no está corriendo)
flutter emulators --launch Pixel_8

# 2. Verificar que esté conectado
flutter devices

# 3. Ejecutar app
flutter run -d emulator-5554
```
- **Primera vez:** 3-5 minutos (instala dependencias)
- **Siguientes veces:** 30-60 segundos
- **Ventaja:** Experiencia real de móvil, prueba gestos
- **Hot reload:** Funciona perfectamente (presiona `r` en consola)

### Opción 3: Android Físico (Tu Teléfono) 📲
```bash
# 1. Habilitar "Depuración USB" en tu teléfono
#    Ajustes → Sistema → Opciones de desarrollador → Depuración USB

# 2. Conectar con cable USB y aceptar popup

# 3. Verificar conexión
flutter devices

# 4. Ejecutar (usa el ID que aparezca)
flutter run -d [device-id]
```

---

## 🎯 Flujo Completo de Usuario

### **Paso 1: Movies Page (Cartelera)**

**Lo que verás:**
- AppBar con gradient rojo → negro
- Filtros de género (Todos, Acción, Terror, Drama, Anime, Comedia)
- Lista horizontal "En Cartelera" con 5 películas scrolleables
- Grid 2 columnas "Próximos Estrenos"

**Qué probar:**
1. **Scroll horizontal** en "En Cartelera"
2. **Scroll vertical** para ver todo el contenido
3. **Tap en filtro de género** - debería cambiar color a rojo
4. **Tap en cualquier película** → Abre bottom sheet

**Películas disponibles:**
- Demon Slayer ⭐4.8 (NUEVO)
- Los Extraños ⭐3.5
- The Dark Knight ⭐4.9
- Avengers: Endgame ⭐4.7 (NUEVO)
- Parasite ⭐4.6

---

### **Paso 2: Movie Detail (Bottom Sheet)**

**Lo que verás:**
- Poster grande (300px altura)
- Título + metadata (duración, clasificación, rating)
- Sinopsis completa
- Director y género
- **Horarios disponibles** (chips seleccionables)
- Botón "Seleccionar Horario"

**Qué probar:**
1. **Drag hacia abajo** - cierra el sheet
2. **Scroll interno** - ver toda la información
3. **Tap en un horario** (ej: 14:30, 17:00) → **Navega a Seat Selection**
4. Horarios disponibles:
   - 14:30
   - 17:00
   - 19:30
   - 22:00

**Nota:** El botón principal "Seleccionar Horario" solo muestra un snackbar recordándote seleccionar arriba.

---

### **Paso 3: Seat Selection (Selección de Asientos)**

**Lo que verás:**
- AppBar con título de película + sala + horario
- Ícono ℹ️ para ver leyenda
- **Pantalla de cine** (indicador curvo gris)
- **Grid de asientos:** 8 filas (A-H) × 12 asientos
  - Pasillo en el medio (entre asiento 6 y 7)
  - Labels de fila a la izquierda (A, B, C...)
- Bottom bar con resumen

**Tipos de asientos:**
- 🟢 **Verde** = Regular disponible ($120)
- 🟠 **Naranja** = VIP disponible ($180) - Filas D, E, F en centro
- 🔵 **Azul con ♿** = Wheelchair accessible ($120) - Esquinas traseras
- ⚫ **Gris con X** = Ocupado (no seleccionable)
- 🔴 **Rojo con borde blanco** = Seleccionado

**Qué probar:**
1. **Tap en ícono ℹ️** → Ver leyenda completa
2. **Tap en asiento verde** → Se pone rojo, aparece en bottom bar
3. **Tap nuevamente** → Deselecciona
4. **Seleccionar múltiples** (hasta 8 máximo)
5. **Intentar asiento ocupado** → No hace nada
6. **Ver precio total** en bottom bar (suma según tipo de asiento)
7. **Ver lista de asientos** seleccionados (ej: "A3, B5, D7")
8. **Tap "Continuar"** → **Navega a Food Menu**

**Ejemplo de precio:**
- 2 asientos regulares (A3, B5) = $240
- 1 asiento VIP (D7) = $180
- **Total = $420**

---

### **Paso 4: Food Menu (Menú de Alimentos)**

**Lo que verás:**
- AppBar con título "Menú de Alimentos"
- Ícono carrito 🛒 con **badge** (muestra cantidad de items)
- **Tabs de categorías:**
  - Combos
  - Palomitas
  - Bebidas
  - Dulces
  - Snacks
- Grid 2 columnas de items de comida
- Bottom bar con resumen de compra

**Items disponibles:**

**Combos:**
- Combo Clásico - $150
- Combo Pareja - $250
- Combo Familia - $450

**Palomitas:**
- Chicas - $60
- Medianas - $80
- Grandes - $110

**Bebidas:**
- Refresco Chico - $40
- Refresco Mediano - $55
- Agua - $35

**Dulces/Snacks:**
- M&Ms - $45
- Skittles - $45
- Nachos - $70

**Qué probar:**
1. **Cambiar categoría** (tap en tabs) → Muestra items de esa categoría
2. **Agregar item** (botón + rojo) → Aparece contador
3. **Incrementar cantidad** (botón +) → Aumenta cantidad
4. **Decrementar cantidad** (botón -) → Disminuye (si llega a 0, desaparece contador)
5. **Tap en ícono carrito** → Abre modal con resumen completo
6. **En modal:** Ver lista de items, cantidades, precios
7. **Modificar cantidades** en modal
8. **"Limpiar todo"** → Vacía carrito
9. **Ver precio total** (asientos + comida)
10. **Botón "Continuar al Pago"** → Actualmente muestra snackbar (TODO)
11. **Botón "Omitir alimentos"** → Para usuarios que no quieren comprar comida

**Ejemplo de compra:**
- Asientos: $420 (de paso anterior)
- Combo Pareja: $250
- Palomitas Grandes: $110
- 2x Refresco Mediano: $110
- **Total = $890**

---

## 🐛 Problemas Conocidos (No Críticos)

### 1. Overflow Warnings en MovieCard
**Síntoma:** Líneas amarillas/negras en algunas cards
**Causa:** Content muy largo en cards pequeñas
**Estado:** En web ya está arreglado, Android puede tener algunos
**Impacto:** Visual solamente, no afecta funcionalidad

### 2. Imágenes Placeholder
**Síntoma:** Algunas imágenes muestran íconos en lugar de fotos reales
**Causa:** URLs de TMDB pueden no cargar, se muestran placeholders
**Estado:** Funcional, las imágenes tienen fallback elegante
**Solución futura:** Usar assets locales o API real

---

## 🔥 Hot Reload (Desarrollo Rápido)

### En Web (Chrome):
1. Cambia código en VS Code
2. Presiona `r` en consola donde corre Flutter
3. O simplemente **F5** en el navegador

### En Android:
1. Cambia código en VS Code
2. Presiona `r` en consola donde corre Flutter
3. **¡Se actualiza en 2-5 segundos!** 🚀

### Hot Restart (Reinicio completo):
- Presiona `R` (mayúscula) en consola
- Útil si hot reload no funciona correctamente

---

## 📊 Estado del Proyecto

### ✅ Completado:
1. **Movies Page** - Lista de películas con filtros
2. **Movie Detail Sheet** - Información completa de película
3. **Seat Selection** - Grid interactivo de asientos, 3 tipos, ocupados simulados
4. **Food Menu** - Catálogo completo con carrito de compras, 5 categorías, 12 items
5. **Navegación** - Movies → Detail → Seats → Food
6. **Estado Global** - Riverpod mantiene: película, función, asientos, comida
7. **Design System** - Colores, tipografía, espaciado consistentes

### ⏳ Pendiente:
1. **Checkout Summary** - Resumen final de compra
2. **Payment Page** - Formulario de pago (mock)
3. **Confirmation** - Pantalla de confirmación con ticket/QR
4. **Navegación Completa** - Bottom nav bar o drawer
5. **Login/Register** - Autenticación de usuario
6. **User Profile** - Perfil y historial
7. **Admin Dashboard** - Gestión de películas, salas, reportes
8. **Integración Firebase** - API real, autenticación, Firestore

---

## 🎨 Design System Implementado

### Colores:
- **Primary:** Cinema Red (#DC2626)
- **Background:** Almost Black (#0A0A0A)
- **Surface:** Dark Gray (#1A1A1A)
- **Success:** Green (#10B981) - Asientos regulares
- **Warning:** Orange (#F59E0B) - Asientos VIP
- **Info:** Blue (#3B82F6) - Wheelchair
- **Error:** Red (#EF4444)

### Tipografía:
- **Display:** Títulos grandes
- **Headline:** Encabezados de sección
- **Title:** Subtítulos
- **Body:** Texto general
- **Label:** Texto pequeño, botones

### Espaciado (Base 8px):
- xs = 4px
- sm = 8px
- md = 16px
- lg = 24px
- xl = 32px
- xxl = 48px

---

## 📱 Pruebas Sugeridas

### Prueba 1: Flujo Feliz (Usuario Compra Todo)
1. Abrir app → Ver cartelera
2. Tap en "Demon Slayer"
3. Seleccionar horario 17:00
4. Seleccionar 2 asientos VIP (D5, D6)
5. Continuar
6. Agregar Combo Pareja
7. Agregar Nachos
8. Ver que precio total = asientos + comida
9. (Continuar al pago - TODO)

### Prueba 2: Usuario Selectivo
1. Abrir app
2. Filtrar por "Acción"
3. Tap en "The Dark Knight"
4. Seleccionar horario 19:30
5. Seleccionar solo 1 asiento regular (B3)
6. Continuar
7. **Omitir alimentos**
8. (Debería ir directo a checkout - TODO)

### Prueba 3: Usuario Indeciso
1. Seleccionar película
2. Elegir varios asientos
3. Deseleccionar algunos
4. Continuar
5. Agregar items al carrito
6. Abrir carrito (tap en 🛒)
7. Modificar cantidades
8. Limpiar carrito
9. Agregar de nuevo
10. Continuar

---

## 💡 Tips de Desarrollo

### Ver logs en tiempo real:
```bash
# La consola donde corre flutter run muestra todo
# También puedes abrir DevTools:
flutter pub global run devtools
```

### Limpiar build si hay problemas:
```bash
flutter clean
flutter pub get
flutter run
```

### Cambiar puerto si 5174 está ocupado:
```bash
flutter run -d chrome --web-port=5175
```

### Detach (dejar app corriendo, salir de consola):
- Presiona `d` en la consola
- La app sigue corriendo pero liberas la terminal

---

## 🎯 Próximos Pasos Sugeridos

1. **Completar Checkout Summary** - Mostrar resumen completo antes de pagar
2. **Agregar Payment Mock** - Formulario de pago simulado
3. **Crear Confirmation** - Ticket con QR code
4. **Bottom Navigation** - Home, Tickets, Profile
5. **Login Page** - Autenticación completa
6. **Conectar Firebase** - Cuando tengas credentials

---

## ✅ Checklist de Pruebas

- [ ] App corre en Web (Chrome)
- [ ] App corre en Android (emulador o físico)
- [ ] Ver todas las películas en cartelera
- [ ] Filtros de género funcionan
- [ ] Abrir detalle de película
- [ ] Seleccionar horario → Navega a seats
- [ ] Ver leyenda de asientos (ℹ️)
- [ ] Seleccionar múltiples asientos
- [ ] Deseleccionar asientos
- [ ] Ver precio actualizado en tiempo real
- [ ] Continuar a food menu
- [ ] Cambiar entre categorías de comida
- [ ] Agregar items al carrito
- [ ] Ver badge de cantidad en carrito
- [ ] Abrir modal de carrito
- [ ] Modificar cantidades en modal
- [ ] Limpiar carrito
- [ ] Ver precio total (seats + food)
- [ ] Hot reload funciona (r)
- [ ] Hot restart funciona (R)

---

**¡Todo listo para probar!** 🎉

La app tiene un flujo completo de usuario funcional con:
- ✅ 4 páginas conectadas
- ✅ Estado global con Riverpod
- ✅ UI moderna y consistente
- ✅ Mock data realista
- ✅ Listo para Firebase cuando tengas credentials

**¿Dudas? Revisa esta guía o pregunta!**
