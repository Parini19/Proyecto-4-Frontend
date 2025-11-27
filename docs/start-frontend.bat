@echo off
echo ========================================
echo   Cinema Frontend - Starting...
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Checking Flutter installation...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found. Please install Flutter SDK
    echo Download: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo     Flutter SDK found!
echo.

echo [2/4] Checking Chrome installation...
where chrome >nul 2>&1
if errorlevel 1 (
    echo WARNING: Chrome not found in PATH, Flutter will try to locate it automatically
)
echo.

echo [3/4] Installing dependencies (first time only)...
if not exist "pubspec.lock" (
    echo     Running flutter pub get...
    flutter pub get
) else (
    echo     Dependencies already installed, skipping...
)
echo.

echo [4/4] Starting Flutter Web App...
echo     URL: http://localhost:5173
echo.
echo Press 'r' for hot reload, 'R' for hot restart, 'q' to quit
echo ========================================
echo.

flutter run -d chrome --web-port 5173

pause
