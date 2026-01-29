---
description: Crea endpoints FastAPI asíncronos, seguros y preparados para multi-idioma.
---

Genera lógica de Backend en Python (FastAPI) para AutoLink:

1. **Estándares de Código:**
    * Usa `Pydantic` para validar todos los datos de entrada/salida.
    * Usa `SQLAlchemy` en modo ASÍNCRONO (`async`/`await`).
    * Todos los endpoints de ruta deben ser `async def`.

2. **Contexto Cultural (Importante):**
    * Detecta el header `Accept-Language` en cada petición.
    * Si hay un error (ej. "Usuario no encontrado"), el mensaje devuelto debe estar traducido según ese header.

3. **Seguridad:**
    * Implementa dependencias de seguridad (`Depends`) para validar tokens JWT.
    * Diferencia permisos entre roles: `user`, `mechanic`, `admin`.

4. **Base de Datos:**
    * Usa migraciones (Alembic) para cualquier cambio en modelos.
