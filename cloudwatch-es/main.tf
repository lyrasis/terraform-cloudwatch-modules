# Alarm limits largely taken from here:
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/cloudwatch-alarms.html

locals {
  name_parts = [var.name_prefix, var.name, var.name_suffix]
  name = join("-", [for part in local.name_parts: part if part != "" && part != null])
}

resource "aws_cloudwatch_metric_alarm" "es-cpu" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-cpu"
  alarm_description   = "CPU Usage Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "900"
  evaluation_periods  = "3"
  datapoints_to_alarm = "3"
  namespace           = "AWS/ES"
  metric_name         = "CPUUtilization"
  statistic           = "Maximum"
  threshold           = "80"
  unit                = "Percent"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

locals {
  disk_per_instance = var.instance.ebs_options[0].volume_size / var.instance.cluster_config[0].instance_count
  disk_threshold = local.disk_per_instance * 1024 * 0.25 # convert GB to MB and take 25% of the value
}

resource "aws_cloudwatch_metric_alarm" "es-disk" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-disk"
  alarm_description   = "Disk Space Usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/ES"
  metric_name         = "FreeStorageSpace"
  statistic           = "Minimum"
  threshold           = local.disk_threshold
  unit                = "Megabytes"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "es-ram" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-ram"
  alarm_description   = "RAM Usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "3"
  datapoints_to_alarm = "3"
  namespace           = "AWS/ES"
  metric_name         = "JVMMemoryPressure"
  statistic           = "Maximum"
  threshold           = "80"
  unit                = "Percent"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

locals {
  is_t_instance = substr(var.instance.cluster_config[0].instance_type, 0, 1) == "t"
}

resource "aws_cloudwatch_metric_alarm" "es-credit" {
  count               = local.is_t_instance && var.enable ? 1 : 0
  alarm_name          = "${local.name}-cpu-credit"
  alarm_description   = "CPU Credit Balance"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "600"
  evaluation_periods  = "1"
  namespace           = "AWS/ES"
  metric_name         = "CPUCreditBalance"
  statistic           = "Minimum"
  threshold           = 0
  unit = "Count"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "es-status-red" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-status-red"
  alarm_description   = "ClusterStatus Red"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "60"
  evaluation_periods  = "1"
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.red"
  statistic           = "Maximum"
  threshold           = "1"
  unit                = "Count"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "es-status-yellow" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-status-yellow"
  alarm_description   = "ClusterStatus Yellow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "60"
  evaluation_periods  = "1"
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.yellow"
  statistic           = "Maximum"
  threshold           = "1"
  unit                = "Count"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "es-writes-blocked" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-writes-blocked"
  alarm_description   = "Writes blocked"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/ES"
  metric_name         = "ClusterIndexWritesBlocked"
  statistic           = "Maximum"
  threshold           = "1"
  unit                = "Count"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "es-snapshot-failure" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-snapshot-failure"
  alarm_description   = "Snapshot failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "60"
  evaluation_periods  = "1"
  namespace           = "AWS/ES"
  metric_name         = "AutomatedSnapshotFailure"
  statistic           = "Maximum"
  threshold           = "1"
  unit                = "Count"
  dimensions = {
    DomainName = var.instance.domain_name
    ClientId   = var.account_id
  }
  alarm_actions = [var.sns_topic]
}
