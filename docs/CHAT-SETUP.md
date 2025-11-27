# 🚀 Setup Rápido - Chat IA

## ✅ ¿Qué se ha implementado?

He creado un sistema completo de chat IA para recomendaciones de películas que incluye:

### 📁 Archivos creados/modificados:

1. **Modelos y servicios**:
   - `lib/core/models/chat_models.dart` - Modelos de datos del chat
   - `lib/core/services/chat_service.dart` - Servicio HTTP para conectar con OpenAI
   - `lib/core/config/api_config.dart` - ✅ Actualizado con endpoint del chat

2. **Componentes UI**:
   - `lib/core/widgets/floating_chat_bubble.dart` - Chat flotante principal
   - `lib/core/widgets/chat_wrapper.dart` - Wrapper para integrar el chat
   - `lib/features/home/pages/test_chat_page.dart` - Página de prueba

3. **Integración**:
   - `lib/main.dart` - ✅ Integrado automáticamente en HomePage y AdminDashboard

## 🔧 Para probar el chat:

### 1. Verificar backend
Asegúrate que tu backend esté corriendo con el endpoint `/api/chat` disponible.

### 2. Verificar IP
En `lib/core/config/api_config.dart`, línea 6:
```dart
static const String _localIp = '192.168.27.23'; // ⚠️ CAMBIA ESTO A TU IP
```

### 3. Ejecutar la app
```bash
flutter run
```

### 4. Probar el chat
- El chat aparece automáticamente como un ícono flotante azul en la esquina inferior derecha
- Haz clic para expandir el chat
- Escribe mensajes como:
  - "Recomiéndame una película de acción"
  - "¿Qué película me sugieres para ver en familia?"
  - "Busco algo de ciencia ficción"

## 🎯 Funcionalidades del chat:

- **Burbuja flotante** que no interfiere con la UI
- **Animaciones suaves** al abrir/cerrar
- **Indicadores de carga** mientras OpenAI responde
- **Manejo de errores** con mensajes informativos
- **Scroll automático** para nuevos mensajes
- **Mensaje de bienvenida** personalizable
- **Responsive** se adapta a diferentes tamaños de pantalla

## 🐛 Troubleshooting:

### Si el chat no aparece:
1. ✅ **SOLUCIONADO**: El chat ahora aparece tanto en HomePage (usuarios) como AdminDashboard (administradores)
2. Busca el ícono azul de chat en la esquina inferior derecha
3. Si aún no aparece, verifica que hayas hecho login correctamente

### Si hay errores de conexión:
1. Verifica que el backend esté corriendo en el puerto correcto
2. Revisa la IP en `api_config.dart` (línea 6): debe ser tu IP local
3. Comprueba que el endpoint `/api/chat` responda
4. Verifica que no hay problemas de CORS en el backend

### Si OpenAI no responde:
1. Verifica que tu API key esté configurada en el backend
2. Revisa los logs del backend para errores de OpenAI
3. Asegúrate que tienes créditos disponibles en OpenAI
4. Comprueba que el modelo GPT-3.5-turbo esté disponible

### Para probar la conexión:
```bash
# Verifica que el endpoint responde
curl -X POST http://TU_IP:7238/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hola, recomiéndame una película"}'
```

## 📱 Ejemplo de uso:

```dart
// Para agregar el chat a cualquier página
ChatWrapper(
  showChat: true,
  child: TuPaginaAqui(),
)
```

## 🎨 Personalización:

Para cambiar colores, mensajes o comportamiento, revisa:
- `lib/core/widgets/floating_chat_bubble.dart` (componente principal)
- Línea ~45: Mensaje de bienvenida
- Línea ~300: Colores del chat
- Línea ~250: Dimensiones de la ventana

¡El chat está listo para usar! 🎉