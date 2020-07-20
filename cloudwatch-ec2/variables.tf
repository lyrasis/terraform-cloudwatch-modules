variable "instances" {
  description = "A map of aws_instance objects to monitor"
  type = map(object({
    id = string
    instance_type = string
    ami = string
    root_block_device = any
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

variable "cpu_alarm_threshold" {
  type = number
  default = 80
}
