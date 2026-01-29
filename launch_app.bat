@echo off
echo ==========================================
echo      INICIANDO AUTOLINK SYSTEM v1.0
echo ==========================================

echo [1/2] Iniciando Backend Server (Puerto 8000)...
echo Usando Python del entorno virtual directamente...
start "AutoLink Backend" cmd /k "cd backend && venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

echo [2/2] Iniciando Aplicacion Movil (Modo Web Server)...
echo.
echo ------------------------------------------------------------------
echo  ESPERA A QUE APAREZCA EL MENSAJE: 
echo  "lib\main.dart is being served at http://localhost:5555"
echo.
echo  LUEGO ABRE ESA DIRECCION EN TU NAVEGADOR (Chrome o Edge)
echo ------------------------------------------------------------------
echo.
cd mobile
"C:\src\flutter\bin\bin\flutter.bat" run -d web-server --web-port=5555 --web-hostname 0.0.0.0 --web-renderer html

echo.
pause
