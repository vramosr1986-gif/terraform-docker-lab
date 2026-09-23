# ============================================================
# BLOQUE TERRAFORM
# Declara qué providers necesita el proyecto.
# Terraform descargará el plugin de Docker al hacer "terraform init".
# ============================================================
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker" # Provider para gestionar Docker
      version = "~> 3.0"             # Cualquier versión 3.x (no 4.x)
    }
  }
}

# ============================================================
# PROVIDER DOCKER
# Configura cómo Terraform se conecta a Docker.
# Sin argumentos, usa el socket local por defecto:
#   - Linux/WSL: /var/run/docker.sock
#   - Windows/Mac: Docker Desktop
# ============================================================
provider "docker" {}

# ============================================================
# IMÁGENES
# Terraform descarga estas imágenes desde Docker Hub.
# keep_locally = true evita que se borren al hacer "terraform destroy".
# ============================================================
resource "docker_image" "nginx" {
  name         = "nginx:1.25-alpine" # Imagen oficial de nginx, ligera
  keep_locally = true                # No borrar la imagen al destruir
}

resource "docker_image" "postgres" {
  name         = "postgres:15" # Imagen oficial de PostgreSQL 15
  keep_locally = true
}

resource "docker_image" "adminer" {
  name         = "adminer:latest" # Interfaz web para gestionar bases de datos
  keep_locally = true
}

# ============================================================
# RED
# Red interna para que los contenedores se comuniquen por nombre
# (web, db, adminer). Sin esto, no se verían entre ellos.
# ============================================================
resource "docker_network" "app_network" {
  name = "app-network"
}

# ============================================================
# VOLUMEN
# Volumen persistente para Postgres. Sin esto, los datos se
# pierden al destruir el contenedor.
# ============================================================
resource "docker_volume" "postgres_data" {
  name = "postgres-data"
}

# ============================================================
# CONTENEDOR NGINX
# Servidor web accesible desde http://localhost:8080
# ============================================================
resource "docker_container" "nginx" {
  name  = "web"                       # Nombre del contenedor en Docker
  image = docker_image.nginx.image_id # Usa la imagen descargada arriba

  ports {
    internal = 80             # Puerto dentro del contenedor
    external = var.nginx_port # Puerto en tu portátil (variables.tf)
  }

  volumes {
    host_path      = "${abspath(path.root)}/html"
    container_path = "/usr/share/nginx/html"
  }
  networks_advanced {
    name = docker_network.app_network.name # Conecta a la red interna
  }
}


# ============================================================
# CONTENEDOR POSTGRES
# Base de datos. No expone puerto al exterior: solo se accede
# desde Adminer o desde dentro de la red interna.
# ============================================================
resource "docker_container" "postgres" {
  name  = "db"
  image = docker_image.postgres.image_id

  # Variables de entorno que Postgres usa al arrancar por primera vez
  env = [
    "POSTGRES_USER=admin",                        # Usuario admin
    "POSTGRES_PASSWORD=${var.postgres_password}", # Password desde variables.tf
    "POSTGRES_DB=appdb"                           # Base de datos inicial
  ]

  # Monta el volumen persistente donde Postgres guarda los datos
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }
}

# ============================================================
# CONTENEDOR ADMINER
# Interfaz web para gestionar Postgres. Accesible en
# http://localhost:8081
# ============================================================
resource "docker_container" "adminer" {
  name  = "adminer"
  image = docker_image.adminer.image_id

  ports {
    internal = 8080 # Adminer escucha en 8080 dentro
    external = 8081 # Tú lo ves en 8081 (8080 lo usa nginx)
  }

  networks_advanced {
    name = docker_network.app_network.name
  }
}