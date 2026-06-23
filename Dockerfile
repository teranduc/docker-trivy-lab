# =============================================
# DOCKERFILE VULNERABLE - LABORATORIO TRIVY
# =============================================
#
# OBJETIVO: Identificar y corregir los problemas de seguridad
# que detecta Trivy para que el escaneo pase sin errores.
#
# LISTADO DE ACCIONES A REALIZAR:
#
# [ ] 1. Cambiar la imagen base debian:10 (EOL) por debian:12-slim
#        → Elimina la mayoría de CVEs HIGH/CRITICAL
#
# [ ] 2. Unificar los RUN de apt-get en un solo comando encadenado
#        → apt-get update && apt-get install -y ... && rm -rf /var/lib/apt/lists/*
#        → Menos capas, sin caché residual, imagen más ligera
#
# [ ] 3. Eliminar el secreto hardcodeado (SECRET_KEY=...)
#        → Los secretos nunca van en la imagen; usar variables de entorno en runtime
#
# [ ] 4. Activar el usuario no-root ya creado (appuser)
#        → Añadir USER appuser antes del CMD
#
# [ ] 5. Reemplazar el CMD con la backdoor de netcat
#        → Sustituir por un servidor legítimo, p.ej. python3 -m http.server
#
# =============================================

# === IMAGEN BASE ===
FROM debian:13-slim

# === INSTALACIÓN DE PAQUETES ===
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# === USUARIO ===
RUN useradd -m -u 1001 appuser
USER appuser

# === COPIA DE LA APP ===
WORKDIR /app
# Cambia el propietario y el grupo del archivo index.html a appuser en el mismo momento en que se copia a la imagen.
COPY --chown=appuser:appuser index.html /app/index.html

# === INFORMACIÓN DEL SISTEMA ===
# Usuario no root no puede exponer puertos < 1024
EXPOSE 8080

# === COMANDO DE INICIO ===
# Reemplazar por un comando seguro
CMD ["python3", "-m", "http.server", "8080"]

# =============================================
# RESUMEN DE CAMBIOS RECOMENDADOS:
# - Imagen base moderna y mínima
# - Usuario no-root
# - Sin secretos en la imagen
# - Menos capas (mejor cache y seguridad)
# - CMD seguro
# =============================================
