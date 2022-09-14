resource "aws_rds_cluster_instance" "demo-database-instance-1" {

  #... db configuration...

  #allocated_storage    = 1
  cluster_identifier         = aws_rds_cluster.demo-database.cluster_identifier
  engine             = "aurora-postgresql"
  engine_version     = "13.6"
  instance_class     = "db.t4g.large"
  #name                        = "mydb"
  #username = "postgres"
  #password                    = "bhanu123"
  #parameter_group_name         = "default.aurora-postgresql13"
  #skip_final_snapshot          = true
  #max_allocated_storage        = 0
  apply_immediately            = true
  #storage_encrypted            = true
  performance_insights_enabled = true
  #publicly_accessible         = true
  monitoring_interval             = 60
  #enabled_cloudwatch_logs_exports = []
  promotion_tier                  = "2"
  # the above deatiled or db configuration will be copied from the terraform.tfstate file for further action.






}


resource "aws_rds_cluster" "demo-database" {
  # (resource arguments)
  cluster_identifier      = "demo-database"
  engine                  = "aurora-postgresql"
  backup_retention_period = 7
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = true

}

#autoscaling 

resource "aws_appautoscaling_target" "replicas" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.demo-database.id}"
  min_capacity       = 0
  max_capacity       = 15
}

resource "aws_appautoscaling_policy" "replicas" {
  name               = "cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.replicas.service_namespace
  scalable_dimension = aws_appautoscaling_target.replicas.scalable_dimension
  resource_id        = aws_appautoscaling_target.replicas.resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}