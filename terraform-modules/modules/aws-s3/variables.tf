variable "name" {
  description = "bucket name, has to be globally unique (yes, really)"
  type        = string
}

variable "versioning" {
  type    = bool
  default = true
}

variable "public" {
  description = "leave false unless you know why you need this"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
