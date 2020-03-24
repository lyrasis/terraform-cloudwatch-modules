variable "disks" {
  type = map(object({
    instance = object({
      id = string
      instance_type = string
      ami = string
    })
    volume = object({
      id = string
      size = number
    })
    path = string
  }))
}

variable "sns_topic" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "storage_fstype" {
  type = string
  default = "ext4"
}

variable "enable" {
  type = bool
  default = true
}

# The module will create on alarm on either free disk space
# or percent free space, whichever is smaller. This sets a
# maximum amount of size that we wish to have free.

variable "percent_alarm_threshold" {
  type = number
  default = 90
}

variable "bytes_alarm_threshold" {
  type = number
  default = 50
}
