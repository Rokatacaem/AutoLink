@echo off
echo Iniciando instalacion de Android SDK...
echo Por favor, acepta los permisos de Administrador si se solicitan.
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0install_android_sdk.ps1""' -Verb RunAs}"
echo Script iniciado en nueva ventana. Por favor espera a que termine.
pause
