# Imagen base
FROM ubuntu:20.04

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    software-properties-common && \
    apt-get clean

# Descargar VS Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Crear usuario no root para seguridad
RUN useradd -m developer && \
    mkdir /home/developer/project && \
    chown -R developer:developer /home/developer

# Cambiar a usuario no root
USER developer

# Configurar directorio de trabajo
WORKDIR /home/developer/project

# Exponer puerto para acceso web
EXPOSE 8080

# Iniciar VS Code Server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
