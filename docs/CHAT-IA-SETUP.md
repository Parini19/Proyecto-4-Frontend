# 🤖 Chat IA para Recomendaciones de Películas

Esta implementación agrega un chat flotante inteligente que se conecta con OpenAI para proporcionar recomendaciones personalizadas de películas a los usuarios.

## 🚀 Características

- **Burbuja flotante**: Chat accesible desde cualquier pantalla
- **Interfaz intuitiva**: Diseño moderno con animaciones suaves
- **IA conversacional**: Powered by OpenAI GPT-3.5-turbo
- **Respuestas en tiempo real**: Indicadores de carga y estados
- **Manejo de errores**: Mensajes informativos para el usuario

## 📁 Archivos Creados

### Modelos de datos
- `lib/core/models/chat_models.dart` - Modelos para mensajes y comunicación con API

### Servicios
- `lib/core/services/chat_service.dart` - Servicio para conectar con la API de chat

### Widgets
- `lib/core/widgets/floating_chat_bubble.dart` - Componente principal del chat
- `lib/core/widgets/chat_wrapper.dart` - Wrapper para integrar el chat en páginas
- `lib/features/home/pages/chat_demo_page.dart` - Página de demostración

### Configuración
- Actualizado `lib/core/config/api_config.dart` - Agregado endpoint del chat

## 🔧 Backend Requerido

El chat se conecta con el endpoint `POST /api/chat` que debe estar implementado en tu backend:

```csharp
// ChatController.cs
[HttpPost]
public async Task<IActionResult> Post([FromBody] ChatRequest request)
{
    var response = await _chatService.GetChatResponseAsync(request.Message);
    return Ok(new { reply = response });
}
```

## 📱 Uso

### 1. Integración automática
El chat ya está integrado en las páginas principales mediante `ChatWrapper`:

```dart
// En main.dart
return const ChatWrapper(
  child: HomePage(),
  showChat: true,
);
```

### 2. Uso manual en páginas específicas
```dart
import '../../../core/widgets/floating_chat_bubble.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tu contenido aquí
          YourPageContent(),
          // Agregar chat flotante
          const FloatingChatBubble(),
        ],
      ),
    );
  }
}
```

### 3. Página de demostración
```dart
import 'lib/features/home/pages/chat_demo_page.dart';

// Navegar a la página de demo
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const ChatDemoPage(),
));
```

## 🎨 Personalización

### Cambiar colores del chat
El chat utiliza los colores del tema principal de la app. Para personalizar:

```dart
// En floating_chat_bubble.dart, línea ~XXX
Container(
  decoration: BoxDecoration(
    color: Colors.tuColorPersonalizado, // Cambia aquí
    borderRadius: BorderRadius.circular(30),
  ),
)
```

### Modificar mensaje de bienvenida
```dart
// En floating_chat_bubble.dart, initState()
_messages.add(ChatMessage(
  id: '1',
  content: 'Tu mensaje personalizado aquí', // Cambia aquí
  isUser: false,
  timestamp: DateTime.now(),
));
```

### Ajustar dimensiones
```dart
// En floating_chat_bubble.dart, build()
Container(
  width: 320,  // Cambiar ancho
  height: 400, // Cambiar alto
  // ...
)
```

## 🛠️ Configuración Requerida

### 1. Verificar endpoint en api_config.dart
```dart
static String get chatUrl => '$baseUrl/api/chat';
```

### 2. Asegurar que el backend esté corriendo
- El servicio OpenAI debe estar configurado
- El endpoint `/api/chat` debe estar disponible
- CORS debe permitir peticiones desde tu app Flutter

### 3. Dependencias
Ya incluidas en pubspec.yaml:
- `dio: ^5.9.0` - Para peticiones HTTP
- `flutter/material.dart` - Para UI

## 🐛 Troubleshooting

### Error de conexión
- Verifica que la IP en `api_config.dart` sea correcta
- Asegúrate que el backend esté corriendo
- Revisa la configuración de CORS

### Chat no aparece
- Verifica que `ChatWrapper` esté implementado correctamente
- Asegúrate que `showChat: true` esté configurado

### Errores de importación
- Verifica las rutas de los imports
- Ejecuta `flutter clean` y `flutter pub get`

## 💡 Mejoras Futuras

1. **Persistencia**: Guardar historial de chat localmente
2. **Autenticación**: Integrar con sistema de usuarios
3. **Temas**: Modo oscuro/claro para el chat
4. **Notificaciones**: Sonidos o vibración para nuevos mensajes
5. **Multimedia**: Soporte para imágenes de películas en respuestas
6. **Sugerencias rápidas**: Botones con preguntas frecuentes

## 📞 Soporte

Si encuentras algún problema o necesitas ayuda con la implementación, revisa:
1. Los logs del backend para errores de API
2. Los logs de Flutter para errores de frontend
3. La configuración de red y CORS