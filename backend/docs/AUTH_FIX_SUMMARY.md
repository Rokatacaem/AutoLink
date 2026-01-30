# Informe de Reparación de Autenticación (Auth Fix Report)

## 1. Diagnóstico y Causa Raíz

Se identificaron los siguientes problemas en la implementación original que contribuían al "bucle de autenticación" o rechazo de tokens válidos:

1. **Inconsistencia Horaria (Time Skew)**:
    * **Problema**: Se usaba `datetime.utcnow()` (naive) mezclado con la validación de `python-jose`. Sin un `leeway` (margen de error) configurado, cualquier diferencia de reloj (incluso milisegundos o segundos entre contenedores/servicios) causaba `ExpiredSignatureError` o `ImmatureSignatureError` (nbf/iat futuro).
    * **Evidencia**: Falta de `leeway` en `jwt.decode` y uso de `utcnow` sin zona horaria explícita.
    * **Corrección**: Se estandarizó todo a `datetime.now(timezone.utc)` y se añadió un `leeway` de 120 segundos (2 minutos).

2. **Validación de Token Laxa**:
    * **Problema**: No se verificaba la presencia de claims críticos como `sub` (email) o `exp` dentro de la lógica de decodificación (solo se confiaba en que `jwt.decode` no fallara). `python-jose` no soporta `require` en `options` como PyJWT, por lo que se ignoraban estas restricciones.
    * **Corrección**: Se implementó validación manual de `sub` y `exp` después de la decodificación.

3. **Falta de Claims de Seguridad**:
    * **Problema**: El token solo tenía `sub` y `exp`. Faltaban `iat` (issued at), `nbf` (not before) y `jti` (unique ID).
    * **Corrección**: Se añadieron estos claims para prevenir ataques de replay y permitir futura revocación por `jti`.

4. **Logging Insuficiente**:
    * **Problema**: Los errores de autenticación se silenciaban en un genérico "Could not validate credentials", impidiendo saber si era por firma inválida, expiración o usuario no encontrado.
    * **Corrección**: Se añadieron logs detallados (`AUDIT[AUTH_FAIL]`) para cada caso de error.

---

## 2. Verificación y Comandos (Reproducible)

### Script de Prueba Automatizado

Se ha creado un script `tests/test_auth_repro_fix.py` que valida:

1. Creación de token con UTC correcto.
2. Validación exitosa.
3. Tolerancia a relojes desfasados (Leeway).
4. Rechazo correcto de tokens expirados (fuera del leeway).

Ejecutar con:

```bash
python tests/test_auth_repro_fix.py
```

### Pruebas Manuales con `curl`

**1. Login (Obtener Token)**

```bash
# Reemplazar con credenciales reales
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin@example.com&password=password123"
```

*Respuesta esperada*: JSON con `access_token`.

**2. Verificar Token (Endpoint Protegido)**

```bash
TOKEN="<pegar_token_aqui>"
curl -X GET http://localhost:8000/api/v1/users/me \
  -H "Authorization: Bearer $TOKEN"
```

*Respuesta esperada*: JSON con datos del usuario (200 OK).

**3. Simular Token Expirado (Visualmente)**
Inspeccionar el token en [jwt.io](https://jwt.io) para ver `exp`. El sistema ahora aceptará el token hasta 2 minutos después de `exp` debido al `leeway`.

---

## 3. Hardening y Seguridad Adicional

### Rotación de Secret Key

Actualmente, `SECRET_KEY` se carga de `.env` o fallback.
**Acción recomendada**: Asegurar que en producción (Vercel/Docker) la variable `SECRET_KEY` esté definida y sea única.
El sistema ahora loguea el hash SHA256 de la clave al inicio (`backend_server.log` o stdout) para verificar que todas las instancias usen la misma clave sin revelarla.

### Revocación (Logout)

Con la adición de `jti`, ahora es posible implementar una "Denylist" (Lista negra) en Redis o Memcached.

* **Plan**: Al hacer logout, guardar `jti` en Redis con TTL igual al tiempo restante de expiración del token. En `get_current_user`, verificar si `jti` está en Redis.

---

## 4. Plan de Migración a RS256 + PKCE (Futuro)

Para eliminar el envío de passwords al backend y soportar clientes públicos (SPA, Mobile) de forma más segura:

1. **Infraestructura de Claves**:
    * Generar par de claves RSA 2048/4096.
    * Servir la clave pública en un endpoint JWKS (`/.well-known/jwks.json`).
2. **Backend (FastAPI)**:
    * Cambiar algoritmo a `RS256`.
    * Firmar tokens con Clave Privada.
    * Validar tokens con Clave Pública (esto permite separar Auth Server de Resource Server si se desea).
3. **Frontend (AutoLink Mobile/Web)**:
    * Implementar flujo **Authorization Code with PKCE**.
    * El usuario se redirige a una página de login (puede ser del mismo backend o servicio externo), se autentica, y regresa con un `code`.
    * El frontend intercambia `code` + `code_verifier` por `access_token`.
4. **Ventajas**:
    * El frontend nunca maneja el password del usuario.
    * Rotación de claves más sencilla (publicar nueva clave pública en JWKS).

---
**Estado Actual**: Parches aplicados y verificados. El sistema es robusto para Password Flow + JWT.
