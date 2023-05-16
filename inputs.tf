variable "namespace" {
    type = string
    description = "Kubernetes namespace to deploy the application"
    default = "default"
}

variable "name" {
    type = string
    description = "Name of the application"
    default = "postgres"
}

variable "image" {
    type = string
    description = "Docker image to deploy"
    default = "postgres:15.3-alpine"
}

variable "pg_port" {
    type = number
    description = "Port to expose the postgres service"
    default = 5432
}

variable "storage" {
    type = string
    description = "Storage size for the postgres database"
    default = "100Mi"
}

variable "db_user" {
    type = string
    description = "Postgres database user"
}

variable "db_name" {
    type = string
    description = "Postgres database name"
}
