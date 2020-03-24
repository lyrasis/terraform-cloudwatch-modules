variable "instance" {
  type = object({
    domain_name = string
    ebs_options = list(object({
      volume_size = string
    }))
    cluster_config = list(object({
      instance_type = string
      instance_count = number
    }))
  })
}

variable "account_id" {
  type = string
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
