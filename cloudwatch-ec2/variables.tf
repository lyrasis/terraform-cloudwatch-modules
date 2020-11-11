variable "instances" {
  description = "A map of aws_instance objects to monitor"
  type = map(object({
    id = string
    instance_type = string
    ami = string
    root_block_device = any
    credit_specification = any
  }))
}

variable "sns_topic" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "enable" {
  type = bool
  default = true
}

variable "alert_on_insufficient_data" {
  type = bool
  default = true
}

variable "cpu_usage" {
  description = "A map of overrides for the cpu usage alarm"
  type = map(string)
  default = {}
}

variable "credit_charge" {
  description = "A map of overrides for the cpu credit surplus charge alarm"
  type = map(string)
  default = {}
}
