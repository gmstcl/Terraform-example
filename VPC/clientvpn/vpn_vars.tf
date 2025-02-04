variable "server_cert" {
  description = "Path to the certificate file"
  type        = string
  default     = "C:/custom_folder/server.crt"
}


variable "server_private_key" {
  description = "Path to the certificate file"
  type        = string
  default     = "C:/custom_folder/server.key"
}

variable "ca_cert" {
  description = "Path to the certificate file"
  type        = string
  default     = "C:/custom_folder/ca.crt"
}

variable "client_cert" {
  description = "Path to the certificate file"
  type        = string
  default     = "C:/custom_folder/client1.domain.tld.crt"
}

variable "client_private_key" {
  description = "Path to the certificate file"
  type        = string
  default     = "C:/custom_folder/client1.domain.tld.key"
}