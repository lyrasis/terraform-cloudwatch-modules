variable "instance" {
  type = object({
    id = string
    storage_type = string
    instance_class = string
    engine = string
  })
}

variable "sns_topic" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "enable" {
  type = bool
  default = true
}

variable "min_free_disk" {
  description = "Minimum free disk space for DB in GB"
  type = number
  default = 10
}

variable "min_free_ram" {
  description = "Minimum free RAM for DB in MB"
  type = number
  default = 200
}
