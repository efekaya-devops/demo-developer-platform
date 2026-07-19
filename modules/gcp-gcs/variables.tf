variable "name" {
  description = "bucket name, globally unique"
  type        = string
}

variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "EU"
}

variable "storage_class" {
  description = "STANDARD / NEARLINE / COLDLINE / ARCHIVE - cost vs access-speed tradeoff"
  type        = string
  default     = "STANDARD"
}

variable "versioning" {
  type    = bool
  default = true
}

variable "force_destroy" {
  description = "allow deleting a non-empty bucket. demo only, obviously"
  type        = bool
  default     = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
