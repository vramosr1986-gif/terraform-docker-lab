# Terraform Docker Lab

Laboratorio local de **Infrastructure as Code** donde se despliega un stack de servicios con **Terraform** sobre **Docker**. Todo el proyecto está versionado en Git y validado con **GitHub Actions**.

![Terraform](https://img.shields.io/badge/Terraform-1.16-7B42BC?logo=terraform)
![Docker](https://img.shields.io/badge/Docker-27-2496ED?logo=docker)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=githubactions)

---

## Qué incluye

| Servicio | Imagen | URL | Acceso |
|---|---|---|---|
| **nginx** | `nginx:1.25-alpine` | http://localhost:8080 | Público |
| **Adminer** | `adminer:latest` | http://localhost:8081 | Público |
| **Postgres** | `postgres:15` | — | Solo interno |

- **nginx** sirve una página HTML personalizada montada desde `html/`.
- **Adminer** es una interfaz web para gestionar Postgres.
- **Postgres** corre en una red interna, sin puerto expuesto al exterior.

---

## Arquitectura

```mermaid
graph LR
    User[Navegador] -->|8080| Nginx[nginx<br/>contenedor web]
    User -->|8081| Adminer[adminer<br/>contenedor adminer]
    Adminer -->|5432| Postgres[postgres<br/>contenedor db]
    Nginx -.->|app-network| Postgres
    Adminer -.->|app-network| Postgres
    Postgres -->|persiste| Volume[(postgres-data)]
    Nginx -->|lee| HTML[html/index.html]

    terraform-docker-lab/


├── .github/
│   └── workflows/
│       └── terraform.yml       # CI: valida en cada push
├── html/
│   └── index.html              # Página servida por nginx
├── .gitignore                  # Qué NO subir a Git
├── main.tf                     # Recursos de Terraform
├── variables.tf                # Declaración de variables
├── terraform.tfvars            # Valores (NO se sube a Git)
├── outputs.tf                  # URLs y datos al aplicar
└── README.md
# Docker
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker $USER
# Cerrar y reabrir WSL

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform


Cómo desplegar
1. Clonar el repositorio
bash
git clone https://github.com/vramosr1986-gif/terraform-docker-lab.git
cd terraform-docker-lab
2. Crear terraform.tfvars
Este archivo no está en Git por seguridad. Créalo con:

hcl
nginx_port        = 8080
postgres_password = "admin123"
3. Inicializar, validar y aplicar
bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
Escribe yes cuando pregunte.

4. Ver los outputs
bash
terraform output
Debe mostrar:

text
adminer_url        = "http://localhost:8081"
nginx_url          = "http://localhost:8080"
postgres_container = "db"