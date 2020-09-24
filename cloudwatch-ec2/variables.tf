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

variable "cpu_alarm_threshold" {
  type = number
  default = 80
}

variable "evaluation_periods" {
  type = number
  default = 60
}

variable "datapoints_to_alarm" {
  type = number
  default = 45
}

variable "credit_surplus_alarm_threshold" {
  type = number
  default = 0
}
