# Alert you by email if your EC2 server is overloaded
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
    alarm_name = "hello-bank-high-cpu"
    comparison_operator = "GraterThanThreshold"
    evaluvation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120      # check every 2 minutes
    statistic = "Average"
    threshold = 80   # alert if CPU is over 80%
    alarm_description = "EC2 CPU is too high"
    dimensions = {
        InstanceId = module.ec2.instance_id         # now works — ec2/outputs.tf defines this
    }
}