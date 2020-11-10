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
  type = object({
    threshold = number
    period = number
    datapoints = number
  })
  default = {
    threshold = 80
    period = 60
    datapoints = 45
  }
}

variable "credit_surplus" {
  type = object({
    threshold = number
    statistic = string
    period = number
  })
  default = {
    threshold = 0
    statistic = "Average"
    period = 300
  }
}
