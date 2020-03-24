locals {
  disks = var.enable ? var.disks : {}

  alarm_bytes_from_percent = {
    for disk in keys(local.disks):
    disk => (100-var.percent_alarm_threshold) * local.disks[disk].volume_size / 100.0
  }

  percent = {
    for disk in keys(local.disks):
    disk => local.disks[disk]
    if local.alarm_bytes_from_percent[disk] <= var.bytes_alarm_threshold
  }

  size  = {
    for disk in keys(local.disks):
    disk => local.disks[disk]
    if local.alarm_bytes_from_percent[disk] > var.bytes_alarm_threshold
  }
}

resource "aws_cloudwatch_metric_alarm" "io-credit" {
  for_each            = local.disks
  alarm_name          = "${var.name_prefix}-${each.key}-io-credit"
  alarm_description   = "IO Credit Balance"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/EBS"
  metric_name         = "BurstBalance"
  statistic           = "Average"
  threshold           = "10"
  unit                = "Percent"
  dimensions = {
    VolumeId = each.value.volume_id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  for_each            = local.percent
  alarm_name          = "${var.name_prefix}-${each.key}-disk"
  alarm_description   = "Disk Space Usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "CWAgent"
  metric_name         = "disk_used_percent"
  statistic           = "Average"
  threshold           = var.percent_alarm_threshold
  unit                = "Percent"
  dimensions = {
    InstanceId    = each.value.instance_id
    ImageId       = each.value.instance_ami
    InstanceType  = each.value.instance_type
    fstype        = var.storage_fstype
    path          = each.value.volume_path
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "disk_used_bytes" {
  for_each            = local.size
  alarm_name          = "${var.name_prefix}-${each.key}-disk"
  alarm_description   = "Disk Space Free"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "CWAgent"
  metric_name         = "disk_free"
  statistic           = "Average"
  threshold           = var.bytes_alarm_threshold * pow(2, 30) # convert GiB to B
  unit                = "Bytes"
  dimensions = {
    InstanceId    = each.value.instance_id
    ImageId       = each.value.instance_ami
    InstanceType  = each.value.instance_type
    fstype        = var.storage_fstype
    path          = each.value.volume_path
  }
  alarm_actions = [var.sns_topic]
}
