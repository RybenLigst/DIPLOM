variable "project_name" {
  description = "A prefix for your project resources"
  type        = string
  default     = "myproject"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "proj"
}

variable "cluster_version" {
  description = "EKS Cluster version"
  type        = string
  default     = "1.27"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.large"
}

variable "db_password" {
  description = "Password for the MySQL root user"
  type        = string
  sensitive   = true
}

variable "jenkins_ami_id" {
  description = "AMI ID for Jenkins server"
  type        = string
  default     = "ami-08eb150f611ca277f"
}

variable "grafana_ami_id" {
  description = "AMI ID for Grafana server"
  type        = string
  default     = "ami-08eb150f611ca277f"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to access SSH on EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_jenkins_cidrs" {
  description = "List of CIDR blocks allowed to access Jenkins UI"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_grafana_cidrs" {
  description = "List of CIDR blocks allowed to access Grafana UI"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
