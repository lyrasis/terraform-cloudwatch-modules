locals {
  # If this module is disabled, then instances should be empty
  instances = var.enable ? var.instances : {}

  # All the instances with a t instance type
  t_instances = toset([
    for instance in keys(local.instances):
      instance
      if substr(var.instances[instance].instance_type, 0, 1) == "t"
  ])
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each            = local.instances
  alarm_name          = "${var.name_prefix}-${each.key}-cpu"
  alarm_description   = "CPU Usage Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "60"
  evaluation_periods  = "60"
  datapoints_to_alarm = "45"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  unit                = "Percent"
  dimensions = {
    InstanceId = each.value.id
  }
  alarm_actions = [var.sns_topic]
  insufficient_data_actions = var.alert_on_insufficient_data ? [var.sns_topic] :  []
}

resource "aws_cloudwatch_metric_alarm" "ram" {
  for_each            = local.instances
  alarm_name          = "${var.name_prefix}-${each.key}-ram"
  alarm_description   = "RAM Usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "CWAgent"
  metric_name         = "mem_available_percent"
  statistic           = "Average"
  threshold           = "10"
  unit                = "Percent"
  dimensions = {
    InstanceId    = each.value.id
    ImageId       = each.value.ami
    InstanceType  = each.value.instance_type
  }
  alarm_actions = [var.sns_topic]
  insufficient_data_actions = var.alert_on_insufficient_data ? [var.sns_topic] :  []
}

resource "aws_cloudwatch_metric_alarm" "credit" {
  for_each            = local.t_instances
  alarm_name          = "${var.name_prefix}-${each.key}-cpu-credit"
  alarm_description   = "CPU Credit Balance"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  namespace           = "AWS/EC2"
  metric_name         = "CPUCreditBalance"
  statistic           = "Average"
  threshold           = 0
  unit                = "Count"
  dimensions = {
    InstanceId = var.instances[each.key].id
  }
  alarm_actions = [var.sns_topic]
  insufficient_data_actions = var.alert_on_insufficient_data ? [var.sns_topic] :  []
}

# https://aws.amazon.com/blogs/aws/new-auto-recovery-for-amazon-ec2/
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html
resource "aws_cloudwatch_metric_alarm" "autorecover" {
  for_each            = local.instances
  alarm_name          = "${var.name_prefix}-${each.key}-autorecover"
  alarm_description   = "Autorecovery from failed state"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  dimensions = {
    InstanceId    = each.value.id
  }
  alarm_actions = [var.sns_topic,"arn:aws:automate:${var.region}:ec2:recover"]
}

module "storage" {
  source = "../cloudwatch-ebs"
  sns_topic = var.sns_topic
  name_prefix = var.name_prefix
  disks = {
    for instance in keys(local.instances):
    instance => {
      instance = var.instances[instance]
      volume = {
        id = var.instances[instance].root_block_device[0].volume_id
        size = var.instances[instance].root_block_device[0].volume_size
      }
      path = "/"
    }
  }
}
