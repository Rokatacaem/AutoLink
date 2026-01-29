---
description: Genera código Flutter limpio con Riverpod, Clean Architecture y estilos de AutoLink.
---

Genera código Flutter para AutoLink siguiendo estas reglas estrictas:

1. **Arquitectura (Clean Arch):**
    * Separa el código en capas: `presentation` (UI), `domain` (Modelos), `data` (Repositorios).
    * Usa `GoRouter` para la navegación.

2. **Gestión de Estado:**
    * Usa `flutter_riverpod` con Code Generation (`@riverpod`).
    * Evita `setState` para lógica de negocio compleja.

3. **Estilo Visual (Design System):**
    * **Scaffold:** Fondo negro absoluto (`Colors.black`).
    * **Botones:** Estilo "Metálico" (Gradientes de gris/plata) o acentos "Tech Blue".
    * **Inputs:** Bordes redondeados, texto blanco, hint gris claro.

4. **Internacionalización (i18n):**
    * **PROHIBIDO** poner texto fijo ("hardcoded") en los widgets.
    * Usa siempre `AppLocalizations.of(context)!.nombreVariable`.
    * Al final de tu respuesta, dame el bloque JSON sugerido para agregar a los archivos `.arb` (inglés y español).
