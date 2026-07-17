variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "europe-west4-a"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "node_count" {
  type    = number
  default = 2
}
