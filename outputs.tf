output "pg_password" {
  value = random_password.this.result
  sensitive = true
  description = "value of the postgres password"
}