output "saludo" {
  value = <<-EOT
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   Vale, sí.                                              ║
║                                                          ║
║   Terraform no se instala solo. El PATH da guerra.       ║
║   WSL tiene sus cosas. Docker pide permisos.             ║
║   Y los archivos hay que rellenarlos a mano.             ║
║                                                          ║
║   Pero eso es exactamente lo que hace un ingeniero:      ║
║   pelearse con el entorno hasta que funciona.            ║
║                                                          ║
║   Cuando termines este proyecto, no solo sabrás          ║
║   Terraform. Sabrás montarlo desde cero.                 ║
║                                                          ║
║   Y eso no se aprende en un curso. Se aprende            ║
║   haciéndolo.                                            ║
║                                                          ║
║   Sigue.                                                 ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
  EOT
}
output "checklist" {
  value = jsonencode({
    proyecto = "terraform-docker-lab"
    pasos = [
      "terraform init",
      "terraform fmt",
      "terraform validate",
      "terraform plan",
      "terraform apply"
    ]
    mensaje = "Un paso cada día. Sin prisa. Sin pausa."
  })
}
output "info" {
  value = jsonencode({
    proyecto = "terraform-docker-lab"
    mensaje  = "Infraestructura como código, paso a paso."
    servicios = {
      nginx    = "http://localhost:${var.nginx_port}"
      adminer  = "http://localhost:8081"
      postgres = docker_container.postgres.name
    }
    tecnologias = ["Terraform", "Docker", "GitHub Actions"]
  })
}
output "debug" {
  value = {
    path_root    = path.root
    path_module  = path.module
    path_cwd     = path.cwd
    abspath_root = abspath(path.root)
    abspath_html = "${abspath(path.root)}/html"
  }
}
output "nginx_url" {
  description = "URL para acceder a nginx"
  value       = "http://localhost:${var.nginx_port}"
}

output "adminer_url" {
  description = "URL para acceder a Adminer"
  value       = "http://localhost:8081"
}

output "postgres_container" {
  description = "Nombre del contenedor de Postgres"
  value       = docker_container.postgres.name
}