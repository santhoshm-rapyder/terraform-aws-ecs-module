variable "vpc_id" {
  description = "VPC ID where ECS instances will be deployed"
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

# variable "ami_id" {
#   description = "The AMI ID for the ECS instances"
#   type        = string
# }

variable "instance_type" {
  description = "The instance type for ECS instances"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "The SSH key name for the instances"
  type        = string
}

variable "ebs_volume_size" {
  description = "The size of the root EBS volume"
  type        = number
  default     = 50
}

variable "security_group_id" {
  description = "The security group for ECS instances"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for ECS"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in Auto Scaling group"
  type        = number
  default     = 0
}

variable "asg_max_size" {
  description = "Maximum number of instances in Auto Scaling group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling group"
  type        = number
  default     = 1
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of Target Group ARNs for ECS instances"
  type        = list(string)
  default     = []
}
