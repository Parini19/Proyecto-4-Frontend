# 🎬 Proyecto 4 - Frontend (Flutter)

Este es el frontend del sistema **Cinema**, desarrollado con Flutter y configurado para correr en **Web** y posteriormente en **Android/iOS**.

---

## 🚀 Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión estable, >= 3.35.x)  
- [VS Code](https://code.visualstudio.com/) con extensiones **Flutter** y **Dart**  
- Google Chrome instalado  

---

## 🛠 Configuración inicial

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/Parini19/Proyecto-4-Frontend.git
   cd Proyecto-4-Frontend
   ```

2. Instalar dependencias:

   ```bash
   flutter pub get
   ```

3. Verificar que los dispositivos web están disponibles:

   ```bash
   flutter devices
   ```

   Debes ver algo como:
   ```
   Chrome (web) • chrome  • web-javascript
   Edge (web)   • edge    • web-javascript
   ```

---

## ▶ Ejecutar el proyecto

### Opción 1: Debug (con breakpoints en VS Code)

- Abre el proyecto en **VS Code**  
- Presiona `F5` o el botón verde ▶  
- Esto corre el proyecto en **http://localhost:5173** apuntando al backend en `https://localhost:7238`.

### Opción 2: Terminal (sin debug)

```bash
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=https://localhost:7238
```

---

## 📦 Tareas rápidas (VS Code)

Se definieron comandos en `.vscode/tasks.json`.  
Ejecuta `Ctrl+Shift+B` y selecciona:

- **Build Flutter Web** → genera el build optimizado (`/build/web`)
- **Analyze Code** → corre análisis estático de Dart
- **Format Code** → aplica formateo automático

---

## 🔗 Integración con Backend

El frontend espera que el **backend** (ASP.NET Core) esté corriendo en:

```
https://localhost:7238
```

Si cambias el puerto del backend, actualiza la variable `API_BASE_URL` en:

- `.vscode/launch.json`
- o en el comando manual de `flutter run`

---
