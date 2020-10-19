locals {
  name_parts = [var.name_prefix, var.name, var.name_suffix]
  name = join("-", [for part in name_parts: part if part != "" and part != null])
}

resource "aws_cloudwatch_metric_alarm" "db-cpu" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-cpu"
  alarm_description   = "CPU Usage Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "60"
  evaluation_periods  = "60"
  datapoints_to_alarm = "45"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  threshold           = "80"
  unit                = "Percent"
  dimensions = {
    DBInstanceIdentifier = var.instance.id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "db-disk" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-disk"
  alarm_description   = "Disk Space Usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  threshold           = var.min_free_disk * pow(10, 9)
  unit                = "Bytes"
  dimensions = {
    DBInstanceIdentifier = var.instance.id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "db-ram" {
  count               = var.enable ? 1 : 0
  alarm_name          = "${local.name}-ram"
  alarm_description   = "RAM Usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  statistic           = "Average"
  threshold           = var.min_free_ram * pow(10, 6)
  unit                = "Bytes"
  dimensions = {
    DBInstanceIdentifier = var.instance.id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "db-credit" {
  count               = substr(var.instance.instance_class, 3, 1) == "t" && var.enable ? 1 : 0
  alarm_name          = "${local.name}-cpu-credit"
  alarm_description   = "CPU Credit Balance"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/RDS"
  metric_name         = "CPUCreditBalance"
  statistic           = "Average"
  threshold           = 0
  unit                = "Count"
  dimensions = {
    DBInstanceIdentifier = var.instance.id
  }
  alarm_actions = [var.sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "db-io-credit" {
  count               = var.instance.storage_type == "gp2" && var.enable ? 1 : 0
  alarm_name          = "${local.name}-io-credit"
  alarm_description   = "Burst-bucket I/O credits"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/RDS"
  metric_name         = "BurstBalance"
  statistic           = "Average"
  threshold           = "10"
  unit                = "Percent"
  dimensions = {
    DBInstanceIdentifier = var.instance.id
  }
  alarm_actions = [var.sns_topic]
}

# extra monitoring for postgresql

#https://aws.amazon.com/blogs/database/implement-an-early-warning-system-for-transaction-id-wraparound-in-amazon-rds-for-postgresql/
resource "aws_cloudwatch_metric_alarm" "db-transaction-id" {
  count               = var.instance.engine == "postgres" && var.enable ? 1 : 0
  alarm_name          = "${local.name}-transaction-id"
  alarm_description   = "Maximum transaction ID in DB"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/RDS"
  metric_name         = "MaximumUsedTransactionIDs"
  statistic           = "Average"
  threshold           = "400000000"
  unit                = "Count"
  dimensions = {
    DBInstanceIdentifier = var.instance.id
  }
  alarm_actions = [var.sns_topic]
}
